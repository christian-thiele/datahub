import 'package:datahub_postgres/schema.dart';

import 'migration.dart';
import 'schema_change.dart';
import 'schema_diff.dart';

/// Turns a migration history and a desired schema into the next migration.
///
/// Everything here is offline. The schema a database *should* have is not read
/// from a database, it is replayed from the changes recorded in the migration
/// files - so generating a migration works in CI, on a laptop without
/// postgres, and produces the same result for everyone.
abstract final class MigrationPlanner {
  /// The schema that results from applying [history] in order.
  static SchemaSnapshot replay(Iterable<Migration> history) {
    var snapshot = SchemaSnapshot.empty;
    for (final migration in history) {
      for (final change in migration.changes) {
        try {
          snapshot = change.apply(snapshot);
        } on SchemaSnapshotException catch (e) {
          throw MigrationHistoryException(
            'Migration "${migration.id}" cannot be replayed: ${e.message} '
            '(while applying "${change.describe()}")',
          );
        }
      }
    }
    return snapshot;
  }

  /// The changes needed to bring the schema described by [history] in line with
  /// [desired].
  static List<SchemaChange> plan(
    Iterable<Migration> history,
    SchemaSnapshot desired,
  ) => SchemaDiff.between(replay(history), desired);

  /// Builds the next migration, or `null` when the history is already up to
  /// date with [desired].
  static Migration? generate({
    required String name,
    required Iterable<Migration> history,
    required SchemaSnapshot desired,
    DateTime? created,
  }) {
    final changes = plan(history, desired);
    if (changes.isEmpty) {
      return null;
    }

    return Migration.ofChanges(
      version: nextVersion(history),
      name: name,
      changes: changes,
      created: created,
    );
  }

  /// Builds an empty migration for changes that have to be written by hand.
  ///
  /// The migration records no [SchemaChange]s, which means it does not move
  /// the replayed schema - whatever it does to the database is invisible to
  /// the diff. That is the point: it is the escape hatch for the things a
  /// generator must not guess at.
  static Migration empty({
    required String name,
    required Iterable<Migration> history,
    DateTime? created,
  }) => Migration(
    version: nextVersion(history),
    name: name,
    created: created ?? DateTime.timestamp(),
    changes: const [],
    sql: '-- Write the statements of this migration here.',
  );

  static int nextVersion(Iterable<Migration> history) =>
      history.fold(0, (max, e) => e.version > max ? e.version : max) + 1;
}

class MigrationHistoryException implements Exception {
  final String message;

  const MigrationHistoryException(this.message);

  @override
  String toString() => 'MigrationHistoryException: $message';
}
