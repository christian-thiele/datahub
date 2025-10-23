// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_host_config.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerHostConfig with DataObject<DockerHostConfig> {
  const $DockerHostConfig();
  static const $$codec = JsonDataCodec();
  static final $networkMode = DataField<DockerHostConfig, String>(
    name: 'networkMode',
    valueOf: (p) => p.networkMode,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $annotations = DataField<DockerHostConfig, Map<String, String>>(
    name: 'annotations',
    valueOf: (p) => p.annotations,
    fromJson: (value, {String? name}) =>
        $$codec.decodeMap<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeMap<String>(value, $$codec.encodeString),
  );

  static final DataBean<DockerHostConfig> bean = DataBean<DockerHostConfig>(
    name: 'DockerHostConfig',
    fields: List<DataField<DockerHostConfig, dynamic>>.unmodifiable([
      $networkMode,
      $annotations,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerHostConfig, dynamic>> get $$fields => bean.fields;
  DockerHostConfig copyWith({
    String? networkMode,
    Map<String, String>? annotations,
  }) {
    final $data = this as DockerHostConfig;
    return DockerHostConfig(
      networkMode: networkMode ?? $data.networkMode,
      annotations: annotations ?? $data.annotations,
    );
  }

  static DockerHostConfig fromValues(Map<String, dynamic> data) {
    return DockerHostConfig(
      networkMode: data['networkMode'],
      annotations: data['annotations'],
    );
  }

  static DockerHostConfig fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        DockerHostConfig,
        data.runtimeType,
        name,
      );
    }
    return DockerHostConfig(
      networkMode: $networkMode.fromJson(
        data['NetworkMode'],
        name: DataCodec.childName(name, 'NetworkMode'),
      ),
      annotations: $annotations.fromJson(
        data['Annotations'],
        name: DataCodec.childName(name, 'Annotations'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerHostConfig;
    return {
      'NetworkMode': $networkMode.toJson($$data.networkMode),
      'Annotations': $annotations.toJson($$data.annotations),
    }..removeWhere((k, v) => v == null);
  }
}
