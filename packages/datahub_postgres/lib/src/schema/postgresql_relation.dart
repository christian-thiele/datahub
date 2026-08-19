import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

import 'postgresql_attribute.dart';
import 'postgresql_table_constraint.dart';

sealed class PostgresqlRelation {
  final String schemaName;
  final String name;
  final List<PostgresqlAttribute> attributes;

  const PostgresqlRelation({
    required this.schemaName,
    required this.name,
    required this.attributes,
  });

  /// The name of this relation, qualified by its schema.
  String get qualifiedName => '$schemaName.$name';

  Future<void> ensureRelation(PostgresqlContext context);
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

    final tableResults = await context.execute(
      SqlSelect(
        SqlQualifiedRelation('information_schema', 'tables'),
        [SqlColumnAttribute('table_name')],
        where: Sql.join([
          RawSql('table_schema = '),
          ParameterSql<String>(schemaName, const PostgresqlString()),
        ]),
      ),
    );

    if (!tableResults.map((e) => e.first.toString()).contains(name)) {
      log.warn(
        'Table "$schemaName"."$name" does not exist. Creating relation.',
      );
      await context.executeLiteral(SqlCreateRelation.of(this));
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

    final viewResults = await context.execute(
      SqlSelect(
        SqlQualifiedRelation('information_schema', 'views'),
        [SqlColumnAttribute('table_name')],
        where: Sql.join([
          RawSql('table_schema = '),
          ParameterSql<String>(schemaName, const PostgresqlString()),
        ]),
      ),
    );

    if (!viewResults.map((e) => e.first.toString()).contains(name)) {
      log.warn('View "$schemaName"."$name" does not exist. Creating relation.');
      await context.executeLiteral(SqlCreateRelation.of(this));
    }
  }
}

class PostgresqlSequence extends PostgresqlRelation {
  PostgresqlSequence({required super.schemaName, required super.name})
    : super(attributes: const []);

  @override
  Future<void> ensureRelation(PostgresqlContext context) async {
    await context.ensureSchema(schemaName);

    final sequenceResults = await context.execute(
      SqlSelect(
        SqlQualifiedRelation('information_schema', 'sequences'),
        [SqlColumnAttribute('sequence_name')],
        where: Sql.join([
          RawSql('sequence_schema = '),
          ParameterSql<String>(schemaName, const PostgresqlString()),
        ]),
      ),
    );

    if (!sequenceResults.map((e) => e.first.toString()).contains(name)) {
      log.warn(
        'Sequence "$schemaName"."$name" does not exist. Creating relation.',
      );
      await context.executeLiteral(SqlCreateRelation.of(this));
    }
  }
}
