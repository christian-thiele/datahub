import 'postgresql_relation.dart';

class PostgresqlSchema {
  final String name;
  final List<PostgresqlRelation> relations;

  const PostgresqlSchema({
    required this.name,
    required this.relations,
  });
}
