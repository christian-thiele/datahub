import 'package:datahub_postgres/schema.dart';
import 'sql.dart';
import 'sql_select.dart';

class SqlQualifiedRelation extends SqlSelectTarget {
  final String? schema;
  final String relation;

  const SqlQualifiedRelation(this.schema, this.relation);

  SqlQualifiedRelation.of(PostgresqlRelation relation)
    : this(relation.schemaName, relation.name);

  @override
  String get name => relation;

  @override
  Sql toSql() => Sql.qualifiedName([?schema, relation]);
}
