// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _Zone with DataObject<Zone> {
  const _Zone();
  static final $id = DataField<Zone, String>(
    name: 'id',
    valueOf: (p) => p.id,
    meta: [
      const Id(),
    ],
  );

  static final $cityId = DataField<Zone, int>(
    name: 'cityId',
    valueOf: (p) => p.cityId,
    meta: [
      const Meta(name: 'City ID'),
    ],
  );

  static final $stateCode = DataField<Zone, String>(
    name: 'stateCode',
    valueOf: (p) => p.stateCode,
    meta: [
      const Meta(name: 'State Code'),
    ],
  );

  static final $countryCode = DataField<Zone, String>(
    name: 'countryCode',
    valueOf: (p) => p.countryCode,
    meta: [
      const Meta(name: 'Country Code'),
    ],
  );

  static final DataBean<Zone> bean = DataBean<Zone>(
    name: 'Zone',
    fields: List<DataField<Zone, dynamic>>.unmodifiable([
      $id,
      $cityId,
      $stateCode,
      $countryCode,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(name: 'Zone', namePlural: 'Zones', icon: 58285),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Zone, dynamic>> get $$fields => bean.fields;
  Zone copyWith({
    String? id,
    int? cityId,
    String? stateCode,
    String? countryCode,
  }) {
    final $data = this as Zone;
    return Zone(
      id: id ?? $data.id,
      cityId: cityId ?? $data.cityId,
      stateCode: stateCode ?? $data.stateCode,
      countryCode: countryCode ?? $data.countryCode,
    );
  }

  static Zone fromValues(Map<String, dynamic> data) {
    return Zone(
      id: data['id'],
      cityId: data['cityId'],
      stateCode: data['stateCode'],
      countryCode: data['countryCode'],
    );
  }

  static Zone fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Zone, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return Zone(
      id: $codec.decodeString(data['id'],
          name: DataCodec.childName(name, 'id')),
      cityId: $codec.decodeInt(data['cityId'],
          name: DataCodec.childName(name, 'cityId')),
      stateCode: $codec.decodeString(data['stateCode'],
          name: DataCodec.childName(name, 'stateCode')),
      countryCode: $codec.decodeString(data['countryCode'],
          name: DataCodec.childName(name, 'countryCode')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as Zone;
    return {
      'id': $codec.encodeString($data.id),
      'cityId': $codec.encodeInt($data.cityId),
      'stateCode': $codec.encodeString($data.stateCode),
      'countryCode': $codec.encodeString($data.countryCode),
    }..removeWhere((k, v) => v == null);
  }
}
