import '../types/postgresql_data_type.dart';
import 'postgresql_attribute_constraint.dart';

class const PostgresqlAttribute({
  required final String name,
  required final PostgresqlDataType type,
  final List<PostgresqlAttributeConstraint> constraints = const [],
}) {
  bool hasConstraint<T extends PostgresqlAttributeConstraint>([
    bool Function(T)? test,
  ]) {
    return constraints.whereType<T>().where(test ?? (_) => true).isNotEmpty;
  }
}
