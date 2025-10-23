// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_network_settings.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerNetworkSettings
    with DataObject<DockerNetworkSettings> {
  const $DockerNetworkSettings();
  static const $$codec = JsonDataCodec();
  static final $networks =
      DataField<DockerNetworkSettings, Map<String, dynamic>>(
        name: 'networks',
        valueOf: (p) => p.networks,
        fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
          value,
          $$codec.decodeDynamic,
          name: name,
        ),
        toJson: (value) =>
            $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
      );

  static final DataBean<DockerNetworkSettings> bean =
      DataBean<DockerNetworkSettings>(
        name: 'DockerNetworkSettings',
        fields: List<DataField<DockerNetworkSettings, dynamic>>.unmodifiable([
          $networks,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerNetworkSettings, dynamic>> get $$fields => bean.fields;
  DockerNetworkSettings copyWith({Map<String, dynamic>? networks}) {
    final $data = this as DockerNetworkSettings;
    return DockerNetworkSettings(networks: networks ?? $data.networks);
  }

  static DockerNetworkSettings fromValues(Map<String, dynamic> data) {
    return DockerNetworkSettings(networks: data['networks']);
  }

  static DockerNetworkSettings fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        DockerNetworkSettings,
        data.runtimeType,
        name,
      );
    }
    return DockerNetworkSettings(
      networks: $networks.fromJson(
        data['Networks'],
        name: DataCodec.childName(name, 'Networks'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerNetworkSettings;
    return {'Networks': $networks.toJson($$data.networks)}
      ..removeWhere((k, v) => v == null);
  }
}
