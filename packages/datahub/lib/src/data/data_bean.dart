import 'package:boost/boost.dart';

import 'data_codec.dart';
import 'data_field.dart';
import 'data_object.dart';
import 'meta/data_field_constraint.dart';
import 'meta/id.dart';
import 'meta/meta_data.dart';
import 'missing_id_field_error.dart';
import 'validation_exception.dart';

/// Contains all "static" properties of a [DataObject].
final class DataBean<T extends DataObject> {
  final String name;
  final List<MetaData> meta;
  final List<DataField<T, dynamic>> fields;
  final T Function(Map<String, dynamic>) fromValues;
  final Decoder<T> fromJson;

  TypeCheck<T> get type => TypeCheck<T>();

  const DataBean({
    required this.name,
    required this.fields,
    required this.fromValues,
    required this.fromJson,
    this.meta = const [],
  });

  // TODO generate?
  DataField<T, dynamic>? get idField =>
      fields.where((field) => field.meta.any((e) => e is Id)).firstOrNull;

  DataField<T, dynamic> get requireIdField =>
      idField ?? (throw MissingIdFieldError(this));

  Map<DataField, List<DataFieldConstraint>> checkConstraints(T object) {
    return {
      for (final field in fields)
        if (field.checkConstraints(field.valueOf(object)) case final result
            when result.isNotEmpty)
          field: result,
    };
  }

  /// Checks constraints (using [checkConstraints]) and throws a
  /// ValidationException containing all violated constraints.
  void validateConstraints(T object) {
    final violatedConstraints = checkConstraints(object);
    if (violatedConstraints.isNotEmpty) {
      throw ValidationException(violatedConstraints);
    }
  }

  bool hasMetaOfType<M extends MetaData>([bool Function(M)? test]) =>
      allMetaOfType<M>(test).isNotEmpty;

  M? metaOfType<M extends MetaData>([bool Function(M)? test]) =>
      allMetaOfType<M>(test).firstOrNull;

  Iterable<M> allMetaOfType<M extends MetaData>([bool Function(M)? test]) =>
      meta.whereType<M>().where(test ?? (_) => true);
}
