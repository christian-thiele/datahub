import 'package:boost/boost.dart';

import 'data_bean.dart';
import 'data_codec.dart';
import 'expression.dart';
import 'meta/data_field_constraint.dart';
import 'meta/meta_data.dart';

class DataField<Data, FieldType>({
  required final String name,
  required FieldType Function(Data) valueOf,
  required final Encoder<FieldType> _toJson,
  required final Decoder<FieldType> _fromJson,
  DataBean Function()? dataBean,
  final List<MetaData> meta = const [],
  final List<DataFieldConstraint> constraints = const [],
  final FieldType? defaultValue,
}) implements Expression {
  final FieldType Function(Data) _valueOf = ((dynamic value) =>
      valueOf(value as Data));
  // this pattern allows for cyclic references
  final DataBean Function()? _resolveDataBean = dataBean;
  late final DataBean? dataBean = _resolveDataBean?.call();

  TypeCheck<Data> get dataType => TypeCheck<Data>();

  TypeCheck<FieldType> get type => TypeCheck<FieldType>();

  FieldType valueOf(Data object) => _valueOf(object);

  dynamic toJson(FieldType object) => _toJson(object);

  FieldType fromJson(dynamic object, {String? name}) =>
      _fromJson(object, name: name);

  /// Validates constraints and returns a list of constraints that are violated.
  List<DataFieldConstraint> checkConstraints(FieldType value) {
    return [...constraints.where((constraint) => !constraint.check(value))];
  }

  bool hasMetaOfType<M extends MetaData>([bool Function(M)? test]) =>
      allMetaOfType<M>(test).isNotEmpty;

  M? metaOfType<M extends MetaData>([bool Function(M)? test]) =>
      allMetaOfType<M>(test).firstOrNull;

  Iterable<M> allMetaOfType<M extends MetaData>([bool Function(M)? test]) =>
      meta.whereType<M>().where(test ?? (_) => true);

  bool hasConstraintOfType<T extends DataFieldConstraint>([
    bool Function(T)? test,
  ]) => constraints.whereType<T>().any(test ?? (_) => true);

  T? constraintOfType<T extends DataFieldConstraint>([
    bool Function(T)? test,
  ]) => constraints.whereType<T>().where(test ?? (_) => true).firstOrNull;
}
