// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_mount_point.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerMountPoint with DataObject<DockerMountPoint> {
  const $DockerMountPoint();
  static const $$codec = JsonDataCodec();
  static final $type = DataField<DockerMountPoint, DockerMountPointType>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, DockerMountPointType.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: DockerMountPointType.values)],
  );

  static final $name = DataField<DockerMountPoint, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $source = DataField<DockerMountPoint, String>(
    name: 'source',
    valueOf: (p) => p.source,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $destination = DataField<DockerMountPoint, String>(
    name: 'destination',
    valueOf: (p) => p.destination,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $driver = DataField<DockerMountPoint, String>(
    name: 'driver',
    valueOf: (p) => p.driver,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $mode = DataField<DockerMountPoint, String>(
    name: 'mode',
    valueOf: (p) => p.mode,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $writable = DataField<DockerMountPoint, bool>(
    name: 'writable',
    valueOf: (p) => p.writable,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $propagation = DataField<DockerMountPoint, String>(
    name: 'propagation',
    valueOf: (p) => p.propagation,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<DockerMountPoint> bean = DataBean<DockerMountPoint>(
    name: 'DockerMountPoint',
    fields: List<DataField<DockerMountPoint, dynamic>>.unmodifiable([
      $type,
      $name,
      $source,
      $destination,
      $driver,
      $mode,
      $writable,
      $propagation,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerMountPoint, dynamic>> get $$fields => bean.fields;
  DockerMountPoint copyWith({
    DockerMountPointType? type,
    String? name,
    String? source,
    String? destination,
    String? driver,
    String? mode,
    bool? writable,
    String? propagation,
  }) {
    final $data = this as DockerMountPoint;
    return DockerMountPoint(
      type: type ?? $data.type,
      name: name ?? $data.name,
      source: source ?? $data.source,
      destination: destination ?? $data.destination,
      driver: driver ?? $data.driver,
      mode: mode ?? $data.mode,
      writable: writable ?? $data.writable,
      propagation: propagation ?? $data.propagation,
    );
  }

  static DockerMountPoint fromValues(Map<String, dynamic> data) {
    return DockerMountPoint(
      type: data['type'],
      name: data['name'],
      source: data['source'],
      destination: data['destination'],
      driver: data['driver'],
      mode: data['mode'],
      writable: data['writable'],
      propagation: data['propagation'],
    );
  }

  static DockerMountPoint fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        DockerMountPoint,
        data.runtimeType,
        name,
      );
    }
    return DockerMountPoint(
      type: $type.fromJson(
        data['Type'],
        name: DataCodec.childName(name, 'Type'),
      ),
      name: $name.fromJson(
        data['Name'],
        name: DataCodec.childName(name, 'Name'),
      ),
      source: $source.fromJson(
        data['Source'],
        name: DataCodec.childName(name, 'Source'),
      ),
      destination: $destination.fromJson(
        data['Destination'],
        name: DataCodec.childName(name, 'Destination'),
      ),
      driver: $driver.fromJson(
        data['Driver'],
        name: DataCodec.childName(name, 'Driver'),
      ),
      mode: $mode.fromJson(
        data['Mode'],
        name: DataCodec.childName(name, 'Mode'),
      ),
      writable: $writable.fromJson(
        data['RW'],
        name: DataCodec.childName(name, 'RW'),
      ),
      propagation: $propagation.fromJson(
        data['Propagation'],
        name: DataCodec.childName(name, 'Propagation'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerMountPoint;
    return {
      'Type': $type.toJson($$data.type),
      'Name': $name.toJson($$data.name),
      'Source': $source.toJson($$data.source),
      'Destination': $destination.toJson($$data.destination),
      'Driver': $driver.toJson($$data.driver),
      'Mode': $mode.toJson($$data.mode),
      'RW': $writable.toJson($$data.writable),
      'Propagation': $propagation.toJson($$data.propagation),
    }..removeWhere((k, v) => v == null);
  }
}
