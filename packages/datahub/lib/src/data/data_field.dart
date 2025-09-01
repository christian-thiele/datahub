import 'package:boost/boost.dart';

import 'meta/meta_data.dart';

import 'data_field_constraint.dart';

class DataField<Data, FieldType> {
  final String name;
  final FieldType Function(Data) valueOf;
  final List<MetaData> meta;
  final List<DataFieldConstraint> constraints;
  TypeCheck<FieldType> get type => TypeCheck<FieldType>();

  const DataField({
    required this.name,
    required this.valueOf,
    this.meta = const [],
    this.constraints = const [],
  });

  /// Validates constraints and returns a list of constraints that are violated.
  List<DataFieldConstraint> checkConstraints(FieldType value) {
    return [
      ...constraints.where((constraint) => constraint.check(value)),
    ];
  }
}
