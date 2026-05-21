import 'package:boost/boost.dart';

import 'meta/meta_data.dart';

import 'data_bean.dart';
import 'data_codec.dart';
import 'expression.dart';
import 'meta/data_field_constraint.dart';

class DataField<Data, FieldType> implements Expression {
  final String name;
  final FieldType Function(Data) _valueOf;
  final List<MetaData> meta;
  final List<DataFieldConstraint> constraints;
  final Encoder<FieldType> _toJson;
  final Decoder<FieldType> _fromJson;

  // this pattern allows for cyclic references
  final DataBean Function()? _resolveDataBean;
  late final DataBean? dataBean = _resolveDataBean?.call();

  TypeCheck<Data> get dataType => TypeCheck<Data>();

  TypeCheck<FieldType> get type => TypeCheck<FieldType>();

  DataField({
    required this.name,
    required FieldType Function(Data) valueOf,
    required Encoder<FieldType> toJson,
    required Decoder<FieldType> fromJson,
    DataBean Function()? dataBean,
    this.meta = const [],
    this.constraints = const [],
  }) : _valueOf = ((dynamic value) => valueOf(value as Data)),
       _toJson = toJson,
       _fromJson = fromJson,
       _resolveDataBean = dataBean;

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
