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

  static final $badge = DataField<City, Uint8List>(
    name: 'badge',
    valueOf: (p) => p.badge,
    meta: [
      const Meta(name: 'Coat of Arms'),
    ],
  );

  static final $location = DataField<City, Geometry>(
    name: 'location',
    valueOf: (p) => p.location,
    meta: [
      const Meta(name: 'Location'),
      const ApertureField(readOnly: true),
    ],
  );

  static final $clientIds = DataField<City, List<String>>(
    name: 'clientIds',
    valueOf: (p) => p.clientIds,
    meta: [
      const Meta(name: 'Client IDs'),
    ],
  );

  static final DataBean<City> bean = DataBean<City>(
    name: 'City',
    fields: List<DataField<City, dynamic>>.unmodifiable([
      $id,
      $name,
      $enabled,
      $badge,
      $location,
      $clientIds,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(name: 'City', namePlural: 'Cities', icon: 58280),
      const ApertureRelation<Zone>(),
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
    Uint8List? badge,
    Geometry? location,
    List<String>? clientIds,
  }) {
    final $data = this as City;
    return City(
      id: id ?? $data.id,
      name: name ?? $data.name,
      enabled: enabled ?? $data.enabled,
      badge: badge ?? $data.badge,
      location: location ?? $data.location,
      clientIds: clientIds ?? $data.clientIds,
    );
  }

  static City fromValues(Map<String, dynamic> data) {
    return City(
      id: data['id'] ?? 0,
      name: data['name'],
      enabled: data['enabled'] ?? false,
      badge: data['badge'],
      location: data['location'],
      clientIds: data['clientIds'],
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
      badge: $codec.decodeUint8List(data['badge'],
          name: DataCodec.childName(name, 'badge')),
      location: $codec.decodeGeometry(data['location'],
          name: DataCodec.childName(name, 'location')),
      clientIds: $codec.decodeList<String>(
          data['clientIds'], $codec.decodeString,
          name: DataCodec.childName(name, 'clientIds')),
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
      'badge': $codec.encodeUint8List($data.badge),
      'location': $codec.encodeGeometry($data.location),
      'clientIds':
          $codec.encodeList<String>($data.clientIds, $codec.encodeString),
    }..removeWhere((k, v) => v == null);
  }
}
