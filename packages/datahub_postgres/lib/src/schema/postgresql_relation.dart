import 'package:datahub_postgres/sql.dart';

import 'postgresql_attribute.dart';

sealed class PostgresqlRelation {
  final String name;
  final List<PostgresqlAttribute> attributes;

  const PostgresqlRelation({
    required this.name,
    required this.attributes,
  });
}

class PostgresqlTable extends PostgresqlRelation {
  const PostgresqlTable({
    required super.name,
    required super.attributes,
  });
}

class PostgresqlView extends PostgresqlRelation {
  final SqlSelect sql;

  const PostgresqlView({
    required super.name,
    required this.sql,
    required super.attributes,
  });
}
