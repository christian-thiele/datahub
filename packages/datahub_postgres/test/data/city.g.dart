// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $City with DataObject<City> {
  const $City();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<City, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id()],
  );

  static final $name = DataField<City, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $zip = DataField<City, String>(
    name: 'zip',
    valueOf: (p) => p.zip,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<City> bean = DataBean<City>(
    name: 'City',
    fields: List<DataField<City, dynamic>>.unmodifiable([$id, $name, $zip]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<City, dynamic>> get $$fields => bean.fields;
  City copyWith({String? id, String? name, String? zip}) {
    final $data = this as City;
    return City(
      id: id ?? $data.id,
      name: name ?? $data.name,
      zip: zip ?? $data.zip,
    );
  }

  static City fromValues(Map<String, dynamic> data) {
    return City(id: data['id'], name: data['name'], zip: data['zip']);
  }

  static City fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(City, data.runtimeType, name);
    }
    return City(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      zip: $zip.fromJson(data['zip'], name: DataCodec.childName(name, 'zip')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as City;
    return {
      'id': $id.toJson($$data.id),
      'name': $name.toJson($$data.name),
      'zip': $zip.toJson($$data.zip),
    }..removeWhere((k, v) => v == null);
  }
}
