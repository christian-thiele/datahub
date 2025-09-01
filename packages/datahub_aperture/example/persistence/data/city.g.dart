// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _City with DataObject<City> {
  const _City();
  static final $id = DataField<City, int>(
    name: 'id',
    valueOf: (p) => p.id,
    meta: [
      const Id(),
      const Meta(name: 'ID'),
      const ApertureField(readOnly: true),
    ],
  );

  static final $name = DataField<City, String>(
    name: 'name',
    valueOf: (p) => p.name,
    meta: [
      const ApertureDisplayField(),
      const Meta(name: 'Name'),
    ],
  );

  static final $enabled = DataField<City, bool>(
    name: 'enabled',
    valueOf: (p) => p.enabled,
    meta: [
      const Meta(name: 'Enabled', description: 'Show in PARCO App'),
    ],
  );

  static final DataBean<City> bean = DataBean<City>(
    name: 'City',
    fields: List<DataField<City, dynamic>>.unmodifiable([
      $id,
      $name,
      $enabled,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(name: 'City', namePlural: 'Cities', icon: 58280),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<City, dynamic>> get $$fields => bean.fields;
  City copyWith({
    int? id,
    String? name,
    bool? enabled,
  }) {
    final $data = this as City;
    return City(
      id: id ?? $data.id,
      name: name ?? $data.name,
      enabled: enabled ?? $data.enabled,
    );
  }

  static City fromValues(Map<String, dynamic> data) {
    return City(
      id: data['id'] ?? 0,
      name: data['name'],
      enabled: data['enabled'] ?? false,
    );
  }

  static City fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(City, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return City(
      id: $codec.decodeInt((data['id'] ?? 0),
          name: DataCodec.childName(name, 'id')),
      name: $codec.decodeString(data['name'],
          name: DataCodec.childName(name, 'name')),
      enabled: $codec.decodeBool((data['enabled'] ?? false),
          name: DataCodec.childName(name, 'enabled')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as City;
    return {
      'id': $codec.encodeInt($data.id),
      'name': $codec.encodeString($data.name),
      'enabled': $codec.encodeBool($data.enabled),
    }..removeWhere((k, v) => v == null);
  }
}
