// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_config_reference.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerConfigReference
    with DataObject<DockerConfigReference> {
  const $DockerConfigReference();
  static const $$codec = JsonDataCodec();
  static final $network = DataField<DockerConfigReference, String?>(
    name: 'network',
    valueOf: (p) => p.network,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<DockerConfigReference> bean =
      DataBean<DockerConfigReference>(
        name: 'DockerConfigReference',
        fields: List<DataField<DockerConfigReference, dynamic>>.unmodifiable([
          $network,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerConfigReference, dynamic>> get $$fields => bean.fields;
  DockerConfigReference copyWith({String? network, bool nullNetwork = false}) {
    final $data = this as DockerConfigReference;
    return DockerConfigReference(
      network: nullNetwork ? null : (network ?? $data.network),
    );
  }

  static DockerConfigReference fromValues(Map<String, dynamic> data) {
    return DockerConfigReference(network: data['network']);
  }

  static DockerConfigReference fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        DockerConfigReference,
        data.runtimeType,
        name,
      );
    }
    return DockerConfigReference(
      network: $network.fromJson(
        data['Network'],
        name: DataCodec.childName(name, 'Network'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerConfigReference;
    return {'Network': $network.toJson($$data.network)}
      ..removeWhere((k, v) => v == null);
  }
}
