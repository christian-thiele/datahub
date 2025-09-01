import 'data_object.dart';
import 'data_field.dart';
import 'data_codec.dart';
import 'meta/meta.dart';

/// Contains all "static" properties of a [DataObject].
final class DataBean<T extends DataObject<T>> {
  final String name;
  final List<Meta> meta;
  final List<DataField<T, dynamic>> fields;
  final T Function(Map<String, dynamic>) fromValues;
  final Decoder<T> fromJson;

  const DataBean({
    required this.name,
    required this.fields,
    required this.fromValues,
    required this.fromJson,
    this.meta = const [],
  });
}
