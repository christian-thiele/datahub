// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_spot.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ParkingSpot with DataObject<ParkingSpot> {
  const _ParkingSpot();
  static final $id = DataField<ParkingSpot, String>(
    name: 'id',
    valueOf: (p) => p.id,
    meta: [
      const Id(),
      const Meta(name: 'Poi ID'),
    ],
  );

  static final $name = DataField<ParkingSpot, String>(
    name: 'name',
    valueOf: (p) => p.name,
    meta: [
      const ApertureDisplayField(),
    ],
  );

  static final $type = DataField<ParkingSpot, ParkingSpotType>(
    name: 'type',
    valueOf: (p) => p.type,
    meta: [
      const ApertureField(enumValues: const [
        ParkingSpotType.parkingGarage,
        ParkingSpotType.carPark,
        ParkingSpotType.parkingPlace,
        ParkingSpotType.parkAndRide,
        ParkingSpotType.onStreetParking
      ]),
    ],
  );

  static final $clientId = DataField<ParkingSpot, String>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
  );

  static final $zoneId = DataField<ParkingSpot, String>(
    name: 'zoneId',
    valueOf: (p) => p.zoneId,
    meta: [
      const RelationId<Zone>(),
    ],
  );

  static final $address = DataField<ParkingSpot, String>(
    name: 'address',
    valueOf: (p) => p.address,
  );

  static final $capacity = DataField<ParkingSpot, List<Capacity>>(
    name: 'capacity',
    valueOf: (p) => p.capacity,
  );

  static final $extraEquipment = DataField<ParkingSpot, ExtraEquipment>(
    name: 'extraEquipment',
    valueOf: (p) => p.extraEquipment,
  );

  static final $context = DataField<ParkingSpot, List<String>>(
    name: 'context',
    valueOf: (p) => p.context,
  );

  static final $geometry = DataField<ParkingSpot, Geometry>(
    name: 'geometry',
    valueOf: (p) => p.geometry,
    meta: [
      const Meta(name: 'Location'),
    ],
  );

  static final DataBean<ParkingSpot> bean = DataBean<ParkingSpot>(
    name: 'ParkingSpot',
    fields: List<DataField<ParkingSpot, dynamic>>.unmodifiable([
      $id,
      $name,
      $type,
      $clientId,
      $zoneId,
      $address,
      $capacity,
      $extraEquipment,
      $context,
      $geometry,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(
          name: 'Parking Spot', namePlural: 'Parking Spots', icon: 58567),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ParkingSpot, dynamic>> get $$fields => bean.fields;
  ParkingSpot copyWith({
    String? id,
    String? name,
    ParkingSpotType? type,
    String? clientId,
    String? zoneId,
    String? address,
    List<Capacity>? capacity,
    ExtraEquipment? extraEquipment,
    List<String>? context,
    Geometry? geometry,
  }) {
    final $data = this as ParkingSpot;
    return ParkingSpot(
      id: id ?? $data.id,
      name: name ?? $data.name,
      type: type ?? $data.type,
      clientId: clientId ?? $data.clientId,
      zoneId: zoneId ?? $data.zoneId,
      address: address ?? $data.address,
      capacity: capacity ?? $data.capacity,
      extraEquipment: extraEquipment ?? $data.extraEquipment,
      context: context ?? $data.context,
      geometry: geometry ?? $data.geometry,
    );
  }

  static ParkingSpot fromValues(Map<String, dynamic> data) {
    return ParkingSpot(
      id: data['id'],
      name: data['name'],
      type: data['type'],
      clientId: data['clientId'],
      zoneId: data['zoneId'],
      address: data['address'],
      capacity: data['capacity'],
      extraEquipment: data['extraEquipment'],
      context: data['context'],
      geometry: data['geometry'],
    );
  }

  static ParkingSpot fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ParkingSpot, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return ParkingSpot(
      id: $codec.decodeString(data['id'],
          name: DataCodec.childName(name, 'id')),
      name: $codec.decodeString(data['name'],
          name: DataCodec.childName(name, 'name')),
      type: $codec.decodeEnum(data['type'], ParkingSpotType.values, name: name),
      clientId: $codec.decodeString(data['clientId'],
          name: DataCodec.childName(name, 'clientId')),
      zoneId: $codec.decodeString(data['zoneId'],
          name: DataCodec.childName(name, 'zoneId')),
      address: $codec.decodeString(data['address'],
          name: DataCodec.childName(name, 'address')),
      capacity: $codec.decodeList<Capacity>(
          data['capacity'], Capacity.bean.fromJson,
          name: DataCodec.childName(name, 'capacity')),
      extraEquipment: ExtraEquipment.bean.fromJson(data['extraEquipment'],
          name: DataCodec.childName(name, 'extraEquipment')),
      context: $codec.decodeList<String>(data['context'], $codec.decodeString,
          name: DataCodec.childName(name, 'context')),
      geometry: $codec.decodeGeometry(data['geometry'],
          name: DataCodec.childName(name, 'geometry')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ParkingSpot;
    return {
      'id': $codec.encodeString($data.id),
      'name': $codec.encodeString($data.name),
      'type': $codec.encodeEnum($data.type),
      'clientId': $codec.encodeString($data.clientId),
      'zoneId': $codec.encodeString($data.zoneId),
      'address': $codec.encodeString($data.address),
      'capacity':
          $codec.encodeList<Capacity>($data.capacity, (v) => v.toJson()),
      'extraEquipment': $data.extraEquipment.toJson(),
      'context': $codec.encodeList<String>($data.context, $codec.encodeString),
      'geometry': $codec.encodeGeometry($data.geometry),
    }..removeWhere((k, v) => v == null);
  }
}
