import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';

import 'migration.dart';
import 'migration_planner.dart';
import 'migration_runner.dart';
import 'migration_store.dart';
import 'schema_change.dart';
import 'schema_diff.dart';

/// The `datahub migrate` subcommands for one postgres schema.
///
/// Two of them - `new` and `plan` - never touch the database: they compare the
/// data model against the schema the migration files add up to. The rest talk
/// to a database because they are about what a particular database has
/// actually had done to it.
class PostgresqlMigrationTool {
  final String schemaName;
  final MigrationStore store;
  final SchemaSnapshot desiredSchema;

  /// Built lazily, so that the offline commands work without a database.
  final MigrationRunner Function() runner;

  const PostgresqlMigrationTool({
    required this.schemaName,
    required this.store,
    required this.desiredSchema,
    required this.runner,
  });

  Future<int> run(MigrationCommand command) async {
    return switch (command.name) {
      'new' => await _new(command),
      'plan' => await _plan(),
      'status' => await _status(),
      'apply' => await _apply(command),
      'verify' => await _verify(),
      'baseline' => await _baseline(),
      final name => _fail('Unknown migration command "$name".'),
    };
  }

  Future<List<Migration>> _history() async =>
      (await store.load()).map((e) => e.migration).toList();

  Future<int> _new(MigrationCommand command) async {
    final history = await _history();

    final Migration migration;
    if (command.has('empty')) {
      final name = command.argument;
      if (name == null) {
        return _fail('Missing migration name: migrate new <name> --empty');
      }
      migration = MigrationPlanner.empty(
        name: MigrationStore.normalizeName(name),
        history: history,
      );
    } else {
      final changes = MigrationPlanner.plan(history, desiredSchema);
      if (changes.isEmpty) {
        stdout.writeln('The migration history already describes the model.');
        return 0;
      }

      final name = command.argument;
      if (name == null) {
        return _fail('Missing migration name: migrate new <name>');
      }

      migration = Migration.ofChanges(
        version: MigrationPlanner.nextVersion(history),
        name: MigrationStore.normalizeName(name),
        changes: changes,
      );
    }

    final file = await store.write(migration);
    stdout.writeln('Wrote ${file.path}');

    if (migration.destructive) {
      stdout.writeln(
        '\nThis migration can lose data. Applying it needs '
        '"migration.allowDestructive" or --allow-destructive.',
      );
    }

    if (migration.requiresReview) {
      stdout.writeln('\nReview needed before it can be applied:');
      for (final reason in migration.review) {
        stdout.writeln('  - $reason');
      }
      stdout.writeln(
        '\nEdit the statements to handle this, then empty the "review" list '
        'in the header.',
      );
    }

    return 0;
  }

  Future<int> _plan() async {
    final changes = MigrationPlanner.plan(await _history(), desiredSchema);
    if (changes.isEmpty) {
      stdout.writeln('The migration history already describes the model.');
      return 0;
    }

    stdout.writeln('A new migration would contain:');
    _writeChanges(changes);
    stdout.writeln('\nRun "datahub migrate new <name>" to write it.');

    // Non-zero so that a CI step can fail on a model that has outrun its
    // migrations.
    return 1;
  }

  Future<int> _status() async {
    final files = await store.load();
    final status = await runner().status(files);

    stdout.writeln('Migrations in schema "$schemaName":');
    stdout.writeln(status.report());

    final changes = MigrationPlanner.plan(
      files.map((e) => e.migration),
      desiredSchema,
    );
    if (changes.isNotEmpty) {
      stdout.writeln(
        '\nThe data model has ${changes.length} change(s) that no migration '
        'describes yet. Run "datahub migrate plan" to see them.',
      );
    }

    return status.problems.isEmpty ? 0 : 1;
  }

  Future<int> _apply(MigrationCommand command) async {
    final dryRun = command.has('dry-run');
    final applied = await runner().apply(
      await store.load(),
      allowDestructive: command.has('allow-destructive'),
      dryRun: dryRun,
    );

    if (applied.isEmpty) {
      stdout.writeln('Nothing to apply.');
      return 0;
    }

    if (dryRun) {
      stdout.writeln('Would apply ${applied.length} migration(s):\n');
      for (final migration in applied) {
        stdout.writeln('-- ${migration.id}');
        stdout.writeln(migration.sql);
        stdout.writeln();
      }
      return 0;
    }

    stdout.writeln('Applied ${applied.length} migration(s):');
    for (final migration in applied) {
      stdout.writeln('  ${migration.id}');
    }
    return 0;
  }

  Future<int> _verify() async {
    final expected = MigrationPlanner.replay(await _history());
    final findings = await runner().verify(expected);

    if (findings.isEmpty) {
      stdout.writeln('Schema "$schemaName" matches the migration history.');
      return 0;
    }

    stdout.writeln('Schema "$schemaName" differs from the migration history:');
    for (final finding in findings) {
      stdout.writeln('  ! $finding');
    }
    return 1;
  }

  Future<int> _baseline() async {
    final history = await store.load();
    if (history.isNotEmpty) {
      return _fail(
        'Baselining needs an empty migration directory, but '
        '${history.length} migration(s) already exist.',
      );
    }

    final actual = await runner().introspect();
    if (actual.relations.isEmpty) {
      return _fail(
        'There is nothing to baseline - schema "$schemaName" is empty. '
        'Use "datahub migrate new initial" instead.',
      );
    }

    final migration = Migration.ofChanges(
      version: 1,
      name: 'baseline',
      changes: SchemaDiff.between(SchemaSnapshot.empty, actual),
    );

    final file = await store.write(migration);
    await runner().baseline(await store.load());

    stdout.writeln(
      'Wrote ${file.path} and recorded it as applied '
      '(${actual.relations.length} relation(s) adopted).',
    );

    final remaining = MigrationPlanner.plan([migration], desiredSchema);
    if (remaining.isNotEmpty) {
      stdout.writeln('\nThe adopted schema still differs from the data model:');
      _writeChanges(remaining);
      stdout.writeln('\nRun "datahub migrate new <name>" to reconcile it.');
    }

    return 0;
  }

  void _writeChanges(List<SchemaChange> changes) {
    for (final change in changes) {
      stdout.writeln('  ${change.describe()}');
      if (change.reviewReason case final reason?) {
        stdout.writeln('      review: $reason');
      }
    }
  }

  int _fail(String message) {
    stderr.writeln(message);
    return 1;
  }
}
