import 'data_field_constraint.dart';

class DataField<Data, FieldType> {
  final String name;
  final FieldType Function(Data) valueOf;
  final List<DataFieldConstraint> constraints;

  const DataField({
    required this.name,
    required this.valueOf,
    this.constraints = const [],
  });

  /// Validates constraints and returns a list of constraints that are violated.
  List<DataFieldConstraint> checkConstraints(FieldType value) {
    return [
      ...constraints.where((constraint) => constraint.check(value)),
    ];
  }
}
