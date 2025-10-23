// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_port.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerPort with DataObject<DockerPort> {
  const $DockerPort();
  static const $$codec = JsonDataCodec();
  static final $ip = DataField<DockerPort, String>(
    name: 'ip',
    valueOf: (p) => p.ip,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $privatePort = DataField<DockerPort, int>(
    name: 'privatePort',
    valueOf: (p) => p.privatePort,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $publicPort = DataField<DockerPort, int>(
    name: 'publicPort',
    valueOf: (p) => p.publicPort,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $type = DataField<DockerPort, String>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<DockerPort> bean = DataBean<DockerPort>(
    name: 'DockerPort',
    fields: List<DataField<DockerPort, dynamic>>.unmodifiable([
      $ip,
      $privatePort,
      $publicPort,
      $type,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerPort, dynamic>> get $$fields => bean.fields;
  DockerPort copyWith({
    String? ip,
    int? privatePort,
    int? publicPort,
    String? type,
  }) {
    final $data = this as DockerPort;
    return DockerPort(
      ip: ip ?? $data.ip,
      privatePort: privatePort ?? $data.privatePort,
      publicPort: publicPort ?? $data.publicPort,
      type: type ?? $data.type,
    );
  }

  static DockerPort fromValues(Map<String, dynamic> data) {
    return DockerPort(
      ip: data['ip'],
      privatePort: data['privatePort'],
      publicPort: data['publicPort'],
      type: data['type'],
    );
  }

  static DockerPort fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(DockerPort, data.runtimeType, name);
    }
    return DockerPort(
      ip: $ip.fromJson(data['IP'], name: DataCodec.childName(name, 'IP')),
      privatePort: $privatePort.fromJson(
        data['PrivatePort'],
        name: DataCodec.childName(name, 'PrivatePort'),
      ),
      publicPort: $publicPort.fromJson(
        data['PublicPort'],
        name: DataCodec.childName(name, 'PublicPort'),
      ),
      type: $type.fromJson(
        data['Type'],
        name: DataCodec.childName(name, 'Type'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerPort;
    return {
      'IP': $ip.toJson($$data.ip),
      'PrivatePort': $privatePort.toJson($$data.privatePort),
      'PublicPort': $publicPort.toJson($$data.publicPort),
      'Type': $type.toJson($$data.type),
    }..removeWhere((k, v) => v == null);
  }
}
