import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_select.dart';

class const SqlQualifiedRelation(final String? schema, final String relation)
    extends SqlSelectTarget {
  new of(PostgresqlRelation relation)
    : this(relation.schemaName, relation.name);

  @override
  String get name => relation;

  @override
  Sql toSql() => Sql.qualifiedName([?schema, relation]);
}
