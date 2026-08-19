import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';
import 'package:postgres/postgres.dart' as pg;

/// Reads the actual shape of a live database.
///
/// Introspection never decides what the next migration should be - that is
/// what the migration history is for. It answers a different question: does
/// this database still look the way the history says it should, and what did
/// an existing database look like at the moment it was adopted.
class PostgresqlIntrospector {
  final String schemaName;

  const PostgresqlIntrospector(this.schemaName);

  Future<SchemaSnapshot> read(PostgresqlContext context) async {
    final relations = await _relations(context);
    final constraints = await _constraints(context);
    final columns = await _columns(context, constraints.primaryKeys);
    final viewDefinitions = await _viewDefinitions(context);

    return SchemaSnapshot.of([
      for (final (name, kind) in relations)
        switch (kind) {
          'r' => TableSnapshot(
            schemaName: schemaName,
            name: name,
            attributes: columns[name] ?? const [],
            constraints: constraints.unique[name] ?? const [],
          ),
          'v' => ViewSnapshot(
            schemaName: schemaName,
            name: name,
            select: viewDefinitions[name] ?? '',
            attributes: [
              for (final column in columns[name] ?? const <AttributeSnapshot>[])
                AttributeSnapshot(name: column.name, type: column.type),
            ],
          ),
          _ => SequenceSnapshot(schemaName: schemaName, name: name),
        },
    ]);
  }

  Future<pg.Result> _query(PostgresqlContext context, String sql) =>
      context.execute(
        RawSql(sql) +
            ParameterSql<String>(schemaName, const PostgresqlString()),
      );

  Future<List<(String, String)>> _relations(PostgresqlContext context) async {
    final result = await _query(
      context,
      // Everything is cast to text: relkind is a "char" and the
      // information_schema columns are domains, none of which the driver
      // decodes on its own.
      'SELECT c.relname::text, c.relkind::text '
      'FROM pg_catalog.pg_class c '
      'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
      "WHERE c.relkind IN ('r', 'v', 'S') "
      // An identity or serial column owns a sequence that nothing declared;
      // reporting it would make every such table look like it drifted.
      'AND NOT EXISTS ('
      '  SELECT 1 FROM pg_catalog.pg_depend d '
      "  WHERE d.objid = c.oid AND d.classid = 'pg_class'::regclass "
      "    AND d.refobjsubid > 0 AND d.deptype IN ('a', 'i')"
      ') '
      'AND n.nspname = ',
    );

    return [for (final row in result) (row[0] as String, row[1] as String)];
  }

  Future<Map<String, List<AttributeSnapshot>>> _columns(
    PostgresqlContext context,
    Map<String, Set<String>> primaryKeys,
  ) async {
    final result = await _query(
      context,
      'SELECT table_name::text, column_name::text, udt_name::text, '
      'is_nullable::text, column_default::text, is_identity::text '
      'FROM information_schema.columns WHERE table_schema = ',
    );

    final columns = <String, List<AttributeSnapshot>>{};
    for (final row in result) {
      final table = row[0] as String;
      final name = row[1] as String;

      columns
          .putIfAbsent(table, () => [])
          .add(
            AttributeSnapshot(
              name: name,
              type: normalizeType(row[2] as String),
              notNull: row[3] == 'NO',
              primaryKey: primaryKeys[table]?.contains(name) ?? false,
              identity: row[5] == 'YES',
              defaultValue: normalizeDefault(row[4] as String?),
            ),
          );
    }
    return columns;
  }

  Future<_Constraints> _constraints(PostgresqlContext context) async {
    final result = await _query(
      context,
      'SELECT tc.table_name::text, tc.constraint_name::text, '
      'tc.constraint_type::text, kcu.column_name::text '
      'FROM information_schema.table_constraints tc '
      'JOIN information_schema.key_column_usage kcu '
      '  ON kcu.constraint_name = tc.constraint_name '
      '  AND kcu.table_schema = tc.table_schema '
      "WHERE tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE') "
      'AND tc.table_schema = ',
    );

    final primaryKeys = <String, Set<String>>{};
    final unique = <String, Map<String, List<String>>>{};

    for (final row in result) {
      final table = row[0] as String;
      final constraint = row[1] as String;
      final column = row[3] as String;

      if (row[2] == 'PRIMARY KEY') {
        primaryKeys.putIfAbsent(table, () => {}).add(column);
      } else {
        unique
            .putIfAbsent(table, () => {})
            .putIfAbsent(constraint, () => [])
            .add(column);
      }
    }

    return _Constraints(
      primaryKeys: primaryKeys,
      unique: {
        for (final table in unique.entries)
          table.key: [
            for (final constraint in table.value.entries)
              TableConstraintSnapshot(
                name: constraint.key,
                attributes: constraint.value,
              ),
          ],
      },
    );
  }

  Future<Map<String, String>> _viewDefinitions(
    PostgresqlContext context,
  ) async {
    final result = await _query(
      context,
      'SELECT c.relname::text, pg_catalog.pg_get_viewdef(c.oid, true)::text '
      'FROM pg_catalog.pg_class c '
      'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
      "WHERE c.relkind = 'v' AND n.nspname = ",
    );

    return {
      for (final row in result)
        row[0] as String: (row[1] as String).trim().replaceAll(
          RegExp(r';\s*$'),
          '',
        ),
    };
  }

  /// Maps a postgres internal type name onto the name used in DDL.
  ///
  /// `information_schema` reports `int8` where a `CREATE TABLE` says `bigint`,
  /// so without this every column would look like it drifted.
  static String normalizeType(String udtName) => switch (udtName) {
    'int2' => 'smallint',
    'int4' => 'integer',
    'int8' => 'bigint',
    'float4' => 'real',
    'float8' => 'double precision',
    'bool' => 'boolean',
    'timestamptz' => 'timestamp with time zone',
    'bpchar' => 'char',
    final other => other,
  };

  /// Strips the type casts postgres adds to a stored default.
  ///
  /// A default written as `nextval('s.t_id_seq')` comes back as
  /// `nextval('s.t_id_seq'::regclass)` - the same expression, spelled
  /// differently.
  static String? normalizeDefault(String? columnDefault) => columnDefault
      ?.replaceAll(RegExp(r'::[a-zA-Z_][a-zA-Z0-9_ ]*(\[\])?'), '')
      .trim();
}

class _Constraints {
  final Map<String, Set<String>> primaryKeys;
  final Map<String, List<TableConstraintSnapshot>> unique;

  const _Constraints({required this.primaryKeys, required this.unique});
}
