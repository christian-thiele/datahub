import '../types/postgresql_data_type.dart';
import 'postgresql_attribute_constraint.dart';

class PostgresqlAttribute {
  final String name;
  final PostgresqlDataType type;
  final List<PostgresqlAttributeConstraint> constraints;

  const PostgresqlAttribute({
    required this.name,
    required this.type,
    this.constraints = const [],
  });

  bool hasConstraint<T extends PostgresqlAttributeConstraint>([
    bool Function(T)? test,
  ]) {
    return constraints.whereType<T>().where(test ?? (_) => true).isNotEmpty;
  }
}
