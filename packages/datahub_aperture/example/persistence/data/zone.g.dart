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
      const Meta(name: 'Zone ID'),
    ],
  );

  static final $clientId = DataField<Zone, String>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
    meta: [
      const Meta(name: 'Client ID'),
    ],
  );

  static final $cityId = DataField<Zone, int>(
    name: 'cityId',
    valueOf: (p) => p.cityId,
    meta: [
      const Meta(name: 'City ID'),
      const RelationId<City>(),
    ],
  );

  static final $payablePerApp = DataField<Zone, bool>(
    name: 'payablePerApp',
    valueOf: (p) => p.payablePerApp,
    meta: [
      const Meta(name: 'Payable per App'),
    ],
  );

  static final $withParcoServiceFee = DataField<Zone, bool>(
    name: 'withParcoServiceFee',
    valueOf: (p) => p.withParcoServiceFee,
    meta: [
      const Meta(name: 'Service Fee'),
    ],
  );

  static final $countryCode = DataField<Zone, String>(
    name: 'countryCode',
    valueOf: (p) => p.countryCode,
    meta: [
      const Meta(name: 'Country Code'),
      const Validation(length: 2),
    ],
  );

  static final $stateCode = DataField<Zone, String>(
    name: 'stateCode',
    valueOf: (p) => p.stateCode,
    meta: [
      const Meta(name: 'State Code'),
      const Validation(length: 2),
    ],
  );

  static final $vignette = DataField<Zone, bool>(
    name: 'vignette',
    valueOf: (p) => p.vignette,
    meta: [
      const Meta(name: 'Vignette Required'),
    ],
  );

  static final DataBean<Zone> bean = DataBean<Zone>(
    name: 'Zone',
    fields: List<DataField<Zone, dynamic>>.unmodifiable([
      $id,
      $clientId,
      $cityId,
      $payablePerApp,
      $withParcoServiceFee,
      $countryCode,
      $stateCode,
      $vignette,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(name: 'Zone', namePlural: 'Zones', icon: 58285),
      const ApertureRelation<ParkingSpot>(),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Zone, dynamic>> get $$fields => bean.fields;
  Zone copyWith({
    String? id,
    String? clientId,
    int? cityId,
    bool? payablePerApp,
    bool? withParcoServiceFee,
    String? countryCode,
    String? stateCode,
    bool? vignette,
  }) {
    final $data = this as Zone;
    return Zone(
      id: id ?? $data.id,
      clientId: clientId ?? $data.clientId,
      cityId: cityId ?? $data.cityId,
      payablePerApp: payablePerApp ?? $data.payablePerApp,
      withParcoServiceFee: withParcoServiceFee ?? $data.withParcoServiceFee,
      countryCode: countryCode ?? $data.countryCode,
      stateCode: stateCode ?? $data.stateCode,
      vignette: vignette ?? $data.vignette,
    );
  }

  static Zone fromValues(Map<String, dynamic> data) {
    return Zone(
      id: data['id'],
      clientId: data['clientId'],
      cityId: data['cityId'],
      payablePerApp: data['payablePerApp'],
      withParcoServiceFee: data['withParcoServiceFee'],
      countryCode: data['countryCode'],
      stateCode: data['stateCode'],
      vignette: data['vignette'],
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
      clientId: $codec.decodeString(data['clientId'],
          name: DataCodec.childName(name, 'clientId')),
      cityId: $codec.decodeInt(data['cityId'],
          name: DataCodec.childName(name, 'cityId')),
      payablePerApp: $codec.decodeBool(data['payablePerApp'],
          name: DataCodec.childName(name, 'payablePerApp')),
      withParcoServiceFee: $codec.decodeBool(data['withParcoServiceFee'],
          name: DataCodec.childName(name, 'withParcoServiceFee')),
      countryCode: $codec.decodeString(data['countryCode'],
          name: DataCodec.childName(name, 'countryCode')),
      stateCode: $codec.decodeString(data['stateCode'],
          name: DataCodec.childName(name, 'stateCode')),
      vignette: $codec.decodeBool(data['vignette'],
          name: DataCodec.childName(name, 'vignette')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as Zone;
    return {
      'id': $codec.encodeString($data.id),
      'clientId': $codec.encodeString($data.clientId),
      'cityId': $codec.encodeInt($data.cityId),
      'payablePerApp': $codec.encodeBool($data.payablePerApp),
      'withParcoServiceFee': $codec.encodeBool($data.withParcoServiceFee),
      'countryCode': $codec.encodeString($data.countryCode),
      'stateCode': $codec.encodeString($data.stateCode),
      'vignette': $codec.encodeBool($data.vignette),
    }..removeWhere((k, v) => v == null);
  }
}
