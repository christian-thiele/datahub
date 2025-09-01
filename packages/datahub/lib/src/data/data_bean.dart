import 'package:boost/boost.dart';

import 'data_object.dart';
import 'data_field.dart';
import 'data_codec.dart';
import 'meta/meta_data.dart';
import 'meta/id.dart';

/// Contains all "static" properties of a [DataObject].
final class DataBean<T extends DataObject<T>> {
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
}
