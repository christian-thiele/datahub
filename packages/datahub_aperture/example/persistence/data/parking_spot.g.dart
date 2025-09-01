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

  static final $zoneId = DataField<ParkingSpot, String>(
    name: 'zoneId',
    valueOf: (p) => p.zoneId,
    meta: [
      const RelationId<Zone>(),
      const Meta(name: 'Zone ID'),
    ],
  );

  static final $name = DataField<ParkingSpot, String>(
    name: 'name',
    valueOf: (p) => p.name,
    meta: [
      const Meta(name: 'Name'),
    ],
  );

  static final $address = DataField<ParkingSpot, String>(
    name: 'address',
    valueOf: (p) => p.address,
    meta: [
      const Meta(name: 'Adresse'),
    ],
  );

  static final DataBean<ParkingSpot> bean = DataBean<ParkingSpot>(
    name: 'ParkingSpot',
    fields: List<DataField<ParkingSpot, dynamic>>.unmodifiable([
      $id,
      $zoneId,
      $name,
      $address,
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
    String? zoneId,
    String? name,
    String? address,
  }) {
    final $data = this as ParkingSpot;
    return ParkingSpot(
      id: id ?? $data.id,
      zoneId: zoneId ?? $data.zoneId,
      name: name ?? $data.name,
      address: address ?? $data.address,
    );
  }

  static ParkingSpot fromValues(Map<String, dynamic> data) {
    return ParkingSpot(
      id: data['id'],
      zoneId: data['zoneId'],
      name: data['name'],
      address: data['address'],
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
      zoneId: $codec.decodeString(data['zoneId'],
          name: DataCodec.childName(name, 'zoneId')),
      name: $codec.decodeString(data['name'],
          name: DataCodec.childName(name, 'name')),
      address: $codec.decodeString(data['address'],
          name: DataCodec.childName(name, 'address')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ParkingSpot;
    return {
      'id': $codec.encodeString($data.id),
      'zoneId': $codec.encodeString($data.zoneId),
      'name': $codec.encodeString($data.name),
      'address': $codec.encodeString($data.address),
    }..removeWhere((k, v) => v == null);
  }
}
