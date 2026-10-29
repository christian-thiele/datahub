// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_of_interest.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $PointOfInterest with DataObject<PointOfInterest> {
  const $PointOfInterest();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<PointOfInterest, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $name = DataField<PointOfInterest, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $type = DataField<PointOfInterest, PointOfInterestType>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? PointOfInterestType.generic),
      PointOfInterestType.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: PointOfInterestType.values)],
  );

  static final $location = DataField<PointOfInterest, Geometry>(
    name: 'location',
    valueOf: (p) => p.location,
    fromJson: (value, {String? name}) => $$codec.decodeGeometry(
      (value ?? const GeometryCollection.empty()),
      name: name,
    ),
    toJson: (value) => $$codec.encodeGeometry(value),
    constraints: [
      const GeometryTypeConstraint<Geometry?>(type: GeometryType.point),
    ],
  );

  static final DataBean<PointOfInterest> bean = DataBean<PointOfInterest>(
    name: 'PointOfInterest',
    fields: List<DataField<PointOfInterest, dynamic>>.unmodifiable([
      $id,
      $name,
      $type,
      $location,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<PointOfInterest, dynamic>> get $$fields => bean.fields;
  PointOfInterest copyWith({
    int? id,
    String? name,
    PointOfInterestType? type,
    Geometry? location,
  }) {
    final $data = this as PointOfInterest;
    return PointOfInterest(
      id: id ?? $data.id,
      name: name ?? $data.name,
      type: type ?? $data.type,
      location: location ?? $data.location,
    );
  }

  static PointOfInterest fromValues(Map<String, dynamic> data) {
    return PointOfInterest(
      id: data['id'] ?? 0,
      name: data['name'],
      type: data['type'] ?? PointOfInterestType.generic,
      location: data['location'] ?? const GeometryCollection.empty(),
    );
  }

  static PointOfInterest fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        PointOfInterest,
        data.runtimeType,
        name,
      );
    }
    return PointOfInterest(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      type: $type.fromJson(
        data['type'],
        name: DataCodec.childName(name, 'type'),
      ),
      location: $location.fromJson(
        data['location'],
        name: DataCodec.childName(name, 'location'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as PointOfInterest;
    return {
      'id': $id.toJson($$data.id),
      'name': $name.toJson($$data.name),
      'type': $type.toJson($$data.type),
      'location': $location.toJson($$data.location),
    }..removeWhere((k, v) => v == null);
  }
}
