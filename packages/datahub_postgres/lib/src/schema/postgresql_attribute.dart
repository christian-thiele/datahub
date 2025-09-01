import 'postgresql_attribute_constraint.dart';
import 'postgresql_data_type.dart';

class PostgresqlAttribute {
  final String name;
  final PostgresqlDataType type;
  final List<PostgresqlAttributeConstraint> constraints;

  const PostgresqlAttribute({
    required this.name,
    required this.type,
    this.constraints = const [],
  });
}
