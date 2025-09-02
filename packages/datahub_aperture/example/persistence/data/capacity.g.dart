// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capacity.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _Capacity with DataObject<Capacity> {
  const _Capacity();
  static final $parkingSpaceType = DataField<Capacity, ParkingSpaceType>(
    name: 'parkingSpaceType',
    valueOf: (p) => p.parkingSpaceType,
    meta: [
      const Meta(name: 'Type'),
      const ApertureField(enumValues: const [
        ParkingSpaceType.total,
        ParkingSpaceType.shortTerm,
        ParkingSpaceType.longTerm,
        ParkingSpaceType.charging,
        ParkingSpaceType.handicapped,
        ParkingSpaceType.family,
        ParkingSpaceType.woman,
        ParkingSpaceType.extraLarge,
        ParkingSpaceType.motorcycle,
        ParkingSpaceType.residents
      ]),
    ],
  );

  static final $capacity = DataField<Capacity, int?>(
    name: 'capacity',
    valueOf: (p) => p.capacity,
  );

  static final DataBean<Capacity> bean = DataBean<Capacity>(
    name: 'Capacity',
    fields: List<DataField<Capacity, dynamic>>.unmodifiable([
      $parkingSpaceType,
      $capacity,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Capacity, dynamic>> get $$fields => bean.fields;
  Capacity copyWith({
    ParkingSpaceType? parkingSpaceType,
    int? capacity,
    bool nullCapacity = false,
  }) {
    final $data = this as Capacity;
    return Capacity(
      parkingSpaceType: parkingSpaceType ?? $data.parkingSpaceType,
      capacity: nullCapacity ? null : (capacity ?? $data.capacity),
    );
  }

  static Capacity fromValues(Map<String, dynamic> data) {
    return Capacity(
      parkingSpaceType: data['parkingSpaceType'],
      capacity: data['capacity'],
    );
  }

  static Capacity fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Capacity, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return Capacity(
      parkingSpaceType: $codec.decodeEnum(
          data['parkingSpaceType'], ParkingSpaceType.values,
          name: name),
      capacity: $codec.decodeNullable(data['capacity'], $codec.decodeInt,
          name: DataCodec.childName(name, 'capacity')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as Capacity;
    return {
      'parkingSpaceType': $codec.encodeEnum($data.parkingSpaceType),
      'capacity': $codec.encodeNullable($data.capacity, $codec.encodeInt),
    }..removeWhere((k, v) => v == null);
  }
}
