import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

import 'postgresql_attribute.dart';
import 'postgresql_table_constraint.dart';

enum PostgresqlRelationKind {
  table,
  partitionedTable,
  view,
  materializedView,
  sequence,
  other;

  bool get isTable => this == table || this == partitionedTable;
}

sealed class PostgresqlRelation {
  final String schemaName;
  final String name;
  final List<PostgresqlAttribute> attributes;

  const PostgresqlRelation({
    required this.schemaName,
    required this.name,
    required this.attributes,
  });

  Future<void> ensureRelation(PostgresqlContext context);

  /// Returns the kind of the relation [name] in [schemaName] or null, if no
  /// such relation exists.
  ///
  /// Unlike `information_schema.tables` (which also lists views), this
  /// distinguishes tables, views and sequences.
  static Future<PostgresqlRelationKind?> findKind(
    PostgresqlContext context,
    String schemaName,
    String name,
  ) async {
    final result = await context.execute(
      Sql.join([
        RawSql(
          'SELECT c.relkind::text FROM pg_catalog.pg_class c '
          'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
          'WHERE n.nspname = ',
        ),
        ParameterSql<String>(schemaName, const PostgresqlString()),
        RawSql(' AND c.relname = '),
        ParameterSql<String>(name, const PostgresqlString()),
      ]),
    );

    return switch (result.firstOrNull?.first) {
      null => null,
      'r' => PostgresqlRelationKind.table,
      'p' => PostgresqlRelationKind.partitionedTable,
      'v' => PostgresqlRelationKind.view,
      'm' => PostgresqlRelationKind.materializedView,
      'S' => PostgresqlRelationKind.sequence,
      _ => PostgresqlRelationKind.other,
    };
  }

  Future<bool> _ensureKind(
    PostgresqlContext context,
    bool Function(PostgresqlRelationKind kind) expected,
    String expectedName,
  ) async {
    final kind = await findKind(context, schemaName, name);
    if (kind == null) {
      return false;
    }

    if (!expected(kind)) {
      throw SqlException(
        'Relation "$schemaName"."$name" already exists as ${kind.name}, '
        'expected $expectedName.',
      );
    }

    return true;
  }
}

class PostgresqlTable extends PostgresqlRelation {
  final List<PostgresqlTableConstraint> constraints;

  const PostgresqlTable({
    required super.schemaName,
    required super.name,
    required super.attributes,
    this.constraints = const [],
  });

  @override
  Future<void> ensureRelation(PostgresqlContext context) async {
    await context.ensureSchema(schemaName);

    if (!await _ensureKind(context, (k) => k.isTable, 'table')) {
      log.warn(
        'Table "$schemaName"."$name" does not exist. Creating relation.',
      );
      await context.executeLiteral(SqlCreateRelation(schemaName, this));
    }
  }
}

class PostgresqlView extends PostgresqlRelation {
  final SqlSelect select;

  const PostgresqlView({
    required super.schemaName,
    required super.name,
    required this.select,
    required super.attributes,
  });

  @override
  Future<void> ensureRelation(PostgresqlContext context) async {
    await context.ensureSchema(schemaName);

    if (!await _ensureKind(
      context,
      (k) => k == PostgresqlRelationKind.view,
      'view',
    )) {
      log.warn('View "$schemaName"."$name" does not exist. Creating relation.');
      await context.executeLiteral(SqlCreateRelation(schemaName, this));
    }
  }
}

class PostgresqlSequence extends PostgresqlRelation {
  PostgresqlSequence({required super.schemaName, required super.name})
    : super(attributes: const []);

  @override
  Future<void> ensureRelation(PostgresqlContext context) async {
    await context.ensureSchema(schemaName);

    if (!await _ensureKind(
      context,
      (k) => k == PostgresqlRelationKind.sequence,
      'sequence',
    )) {
      log.warn(
        'Sequence "$schemaName"."$name" does not exist. Creating relation.',
      );
      await context.executeLiteral(SqlCreateRelation(schemaName, this));
    }
  }
}
