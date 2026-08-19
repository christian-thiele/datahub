import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';
import 'package:postgres/postgres.dart' as pg;

import 'migration.dart';
import 'migration_store.dart';
import 'schema_drift.dart';
import 'schema_introspector.dart';

/// Applies and verifies migrations against a database.
///
/// Every operation that touches the database goes through here, so the CLI and
/// the runtime service behave identically - `migrate apply` and starting an
/// application in [MigrationMode.apply] run the same code.
class MigrationRunner {
  static const trackingRelationName = 'datahub_migration';

  final Postgresql postgresql;
  final String schemaName;
  final String appliedBy;

  const MigrationRunner({
    required this.postgresql,
    required this.schemaName,
    this.appliedBy = 'datahub',
  });

  PostgresqlTable get trackingTable => PostgresqlTable(
    schemaName: schemaName,
    name: trackingRelationName,
    attributes: const [
      PostgresqlAttribute(
        name: 'version',
        type: PostgresqlInt(),
        constraints: [PrimaryKeyConstraint(auto: false), NotNullConstraint()],
      ),
      PostgresqlAttribute(
        name: 'name',
        type: PostgresqlString(),
        constraints: [NotNullConstraint()],
      ),
      PostgresqlAttribute(
        name: 'checksum',
        type: PostgresqlString(),
        constraints: [NotNullConstraint()],
      ),
      PostgresqlAttribute(
        name: 'applied',
        type: PostgresqlDateTime(),
        constraints: [NotNullConstraint(), DefaultConstraint(RawSql('now()'))],
      ),
      PostgresqlAttribute(name: 'duration_ms', type: PostgresqlInt()),
      PostgresqlAttribute(name: 'applied_by', type: PostgresqlString()),
    ],
  );

  /// Creates the tracking table if it does not exist yet.
  ///
  /// This is the one relation that cannot be migrated, so it is the one
  /// relation that is still created on demand.
  Future<void> bootstrap() async {
    try {
      await postgresql.runTransaction((context) async {
        await context.ensureSchema(schemaName);
        await context.executeLiteral(
          SqlCreateRelation.of(trackingTable, ifNotExists: true),
        );
      });
    } on pg.ServerException catch (e) {
      // `IF NOT EXISTS` is not race free - two instances starting together can
      // still collide in the catalog. Losing that race means the table exists,
      // which is all this method was after.
      if (e.code != _duplicateTable && e.code != _uniqueViolation) {
        rethrow;
      }
      log.debug('Migration tracking table was created concurrently.');
    }
  }

  static const _duplicateTable = '42P07';
  static const _uniqueViolation = '23505';

  /// Reads the migrations recorded as applied, ordered by version.
  Future<List<AppliedMigration>> readApplied() async {
    return await postgresql.runTransaction((context) async {
      final result = await context.execute(
        SqlSelect(
          SqlQualifiedRelation(schemaName, trackingRelationName),
          const [
            SqlColumnAttribute('version'),
            SqlColumnAttribute('name'),
            SqlColumnAttribute('checksum'),
            SqlColumnAttribute('applied'),
          ],
          order: const RawSql('"version" ASC'),
        ),
      );

      return [
        for (final row in result)
          AppliedMigration(
            version: row[0] as int,
            name: row[1] as String,
            checksum: row[2] as String,
            applied: row[3] as DateTime,
          ),
      ];
    });
  }

  /// Compares the migration files on disk with what the database recorded.
  Future<MigrationStatus> status(List<MigrationFile> files) async {
    await bootstrap();
    return MigrationStatus(files: files, applied: await readApplied());
  }

  /// Throws unless the database is at the head of the history.
  Future<MigrationStatus> validate(List<MigrationFile> files) async {
    final status = await this.status(files);
    if (status.problems.isNotEmpty || status.pending.isNotEmpty) {
      throw MigrationException(
        'Database schema "$schemaName" does not match the migration history:\n'
        '${status.report()}',
      );
    }
    return status;
  }

  /// Applies every pending migration, in order.
  ///
  /// Each migration runs in its own transaction, and the whole run holds a
  /// session level advisory lock so that starting ten replicas at once still
  /// migrates exactly once.
  ///
  /// When [dryRun] is set the statements are collected and returned without
  /// being executed and without being recorded.
  Future<List<Migration>> apply(
    List<MigrationFile> files, {
    bool allowDestructive = false,
    bool dryRun = false,
  }) async {
    if (dryRun) {
      await bootstrap();
    }

    return await postgresql.useConnection((connection) async {
      final applied = <Migration>[];

      if (!dryRun) {
        // The lock is taken before anything else so that the whole run,
        // bootstrap included, happens in one instance at a time.
        await _lock(connection);
      }

      try {
        await bootstrap();
        // Re-read inside the lock: another instance may have applied
        // everything while this one was waiting for it.
        final status = MigrationStatus(
          files: files,
          applied: await readApplied(),
        );

        if (status.problems.isNotEmpty) {
          throw MigrationException(
            'Refusing to migrate schema "$schemaName":\n${status.report()}',
          );
        }

        for (final pending in status.pending) {
          final migration = pending.migration;

          if (migration.requiresReview) {
            throw MigrationException(
              'Migration "${migration.id}" needs review before it can be '
              'applied:\n'
              '${migration.review.map((e) => '  - $e').join('\n')}\n'
              'Edit ${migration.fileName} to handle this, then empty its '
              '"review" list.',
            );
          }

          if (migration.destructive && !allowDestructive) {
            throw MigrationException(
              'Migration "${migration.id}" is destructive and '
              '"migration.allowDestructive" is not set.',
            );
          }

          if (dryRun) {
            applied.add(migration);
            continue;
          }

          final stopwatch = Stopwatch()..start();
          await connection.runTransaction((context) async {
            log.info('Applying migration "${migration.id}".');
            await context.executeLiteral(RawSql(migration.sql));
            await _record(context, pending, stopwatch.elapsed);
          });
          stopwatch.stop();

          applied.add(migration);
        }
      } finally {
        if (!dryRun) {
          await _unlock(connection);
        }
      }

      return applied;
    });
  }

  /// Records [files] as applied without running them.
  ///
  /// This adopts a database that already has the schema those migrations
  /// describe - the tables predate the migration system, so running the
  /// statements would fail on every one of them.
  Future<List<Migration>> baseline(List<MigrationFile> files) async {
    await bootstrap();

    return await postgresql.useConnection((connection) async {
      await _lock(connection);
      try {
        final status = MigrationStatus(
          files: files,
          applied: await readApplied(),
        );

        for (final pending in status.pending) {
          await connection.runTransaction((context) async {
            log.info('Recording migration "${pending.migration.id}".');
            await _record(context, pending, Duration.zero);
          });
        }

        return status.pending.map((e) => e.migration).toList();
      } finally {
        await _unlock(connection);
      }
    });
  }

  /// Reads the live schema and reports how it differs from [expected].
  Future<List<String>> verify(SchemaSnapshot expected) async {
    return await postgresql.runTransaction((context) async {
      final actual = await PostgresqlIntrospector(schemaName).read(context);
      return SchemaDrift.between(
        expected: expected,
        // The tracking table is not part of any history - it is what records
        // the history - so it is never drift.
        actual: actual.withoutRelation('$schemaName.$trackingRelationName'),
      );
    });
  }

  /// Reads the live schema, as a snapshot that can be turned into a migration.
  Future<SchemaSnapshot> introspect() async {
    return await postgresql.runTransaction((context) async {
      final actual = await PostgresqlIntrospector(schemaName).read(context);
      return actual.withoutRelation('$schemaName.$trackingRelationName');
    });
  }

  Future<void> _record(
    PostgresqlContext context,
    MigrationFile file,
    Duration duration,
  ) async {
    await context.execute(
      SqlInsert(SqlQualifiedRelation(schemaName, trackingRelationName), {
        const SqlTypedColumnAttribute('version', PostgresqlInt()):
            file.migration.version,
        const SqlTypedColumnAttribute('name', PostgresqlString()):
            file.migration.name,
        const SqlTypedColumnAttribute('checksum', PostgresqlString()):
            file.checksum,
        const SqlTypedColumnAttribute('duration_ms', PostgresqlInt()):
            duration.inMilliseconds,
        const SqlTypedColumnAttribute('applied_by', PostgresqlString()):
            appliedBy,
      }),
    );
  }

  Future<void> _lock(PostgresqlConnection connection) async {
    log.debug('Acquiring migration lock for schema "$schemaName".');
    await connection.runTransaction((context) async {
      await context.execute(
        const RawSql('SELECT ') +
            Sql.function('pg_advisory_lock', [
              ParameterSql<int>(lockKey, const PostgresqlInt()),
            ]),
      );
    });
  }

  Future<void> _unlock(PostgresqlConnection connection) async {
    await connection.runTransaction((context) async {
      await context.execute(
        const RawSql('SELECT ') +
            Sql.function('pg_advisory_unlock', [
              ParameterSql<int>(lockKey, const PostgresqlInt()),
            ]),
      );
    });
  }

  /// The advisory lock key for [schemaName].
  ///
  /// Derived in dart rather than with `hashtext` so that the value does not
  /// depend on a postgres internal, and so that it is the same for every
  /// client of the same schema.
  int get lockKey {
    final digest = sha256.convert(utf8.encode('datahub:migration:$schemaName'));
    return ByteData.sublistView(
      Uint8List.fromList(digest.bytes),
    ).getInt64(0, Endian.big);
  }
}

/// A migration as recorded in the tracking table.
class AppliedMigration {
  final int version;
  final String name;
  final String checksum;
  final DateTime applied;

  const AppliedMigration({
    required this.version,
    required this.name,
    required this.checksum,
    required this.applied,
  });
}

/// The comparison of the migration files with the tracking table.
class MigrationStatus {
  final List<MigrationFile> files;
  final List<AppliedMigration> applied;

  const MigrationStatus({required this.files, required this.applied});

  Iterable<int> get _appliedVersions => applied.map((e) => e.version);

  /// Migrations that exist on disk but have not been applied.
  List<MigrationFile> get pending => [
    for (final file in files)
      if (!_appliedVersions.contains(file.migration.version)) file,
  ];

  /// Everything that makes this history unsafe to act on.
  ///
  /// These are not "not migrated yet" - they are signs that the files and the
  /// database tell different stories, which no migration can resolve.
  List<String> get problems {
    final byVersion = {for (final file in files) file.migration.version: file};

    return [
      for (final record in applied)
        if (byVersion[record.version] case final file?) ...[
          if (file.checksum != record.checksum)
            'Migration "${file.migration.id}" was modified after it was '
                'applied on ${record.applied.toIso8601String()}.',
          if (file.migration.name != record.name)
            'Migration ${record.version} was applied as "${record.name}" but '
                'is now named "${file.migration.name}".',
        ] else
          'Migration ${record.version} ("${record.name}") was applied but its '
              'file is missing.',
      // A migration that slots in below something already applied would change
      // the meaning of the history for every database that is further along.
      for (final file in pending)
        if (_appliedVersions.any((e) => e > file.migration.version))
          'Migration "${file.migration.id}" is pending but a later migration '
              'has already been applied.',
    ];
  }

  bool get isUpToDate => pending.isEmpty && problems.isEmpty;

  /// A readable summary for the CLI and for startup failures.
  String report() {
    final buffer = StringBuffer();

    if (files.isEmpty) {
      buffer.writeln('  (no migrations)');
    }

    for (final file in files) {
      final record = applied
          .where((e) => e.version == file.migration.version)
          .firstOrNull;
      buffer.writeln(
        '  ${file.migration.paddedVersion}  ${file.migration.name.padRight(32)}'
        '${record == null ? 'PENDING' : 'applied ${record.applied.toIso8601String()}'}',
      );
    }

    if (problems.isNotEmpty) {
      buffer.writeln();
      for (final problem in problems) {
        buffer.writeln('  ! $problem');
      }
    }

    return buffer.toString().trimRight();
  }
}

class MigrationException implements Exception {
  final String message;

  const MigrationException(this.message);

  @override
  String toString() => 'MigrationException: $message';
}
