// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_ipamconfig.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerIPAMConfig with DataObject<DockerIPAMConfig> {
  const $DockerIPAMConfig();
  static const $$codec = JsonDataCodec();
  static final $subnet = DataField<DockerIPAMConfig, String?>(
    name: 'subnet',
    valueOf: (p) => p.subnet,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $ipRange = DataField<DockerIPAMConfig, String?>(
    name: 'ipRange',
    valueOf: (p) => p.ipRange,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $gateway = DataField<DockerIPAMConfig, String?>(
    name: 'gateway',
    valueOf: (p) => p.gateway,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $auxiliaryAddresses =
      DataField<DockerIPAMConfig, Map<String, String>>(
        name: 'auxiliaryAddresses',
        valueOf: (p) => p.auxiliaryAddresses,
        fromJson: (value, {String? name}) => $$codec.decodeMap<String>(
          (value ?? const {}),
          $$codec.decodeString,
          name: name,
        ),
        toJson: (value) =>
            $$codec.encodeMap<String>(value, $$codec.encodeString),
      );

  static final DataBean<DockerIPAMConfig> bean = DataBean<DockerIPAMConfig>(
    name: 'DockerIPAMConfig',
    fields: List<DataField<DockerIPAMConfig, dynamic>>.unmodifiable([
      $subnet,
      $ipRange,
      $gateway,
      $auxiliaryAddresses,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerIPAMConfig, dynamic>> get $$fields => bean.fields;
  DockerIPAMConfig copyWith({
    String? subnet,
    bool nullSubnet = false,
    String? ipRange,
    bool nullIpRange = false,
    String? gateway,
    bool nullGateway = false,
    Map<String, String>? auxiliaryAddresses,
  }) {
    final $data = this as DockerIPAMConfig;
    return DockerIPAMConfig(
      subnet: nullSubnet ? null : (subnet ?? $data.subnet),
      ipRange: nullIpRange ? null : (ipRange ?? $data.ipRange),
      gateway: nullGateway ? null : (gateway ?? $data.gateway),
      auxiliaryAddresses: auxiliaryAddresses ?? $data.auxiliaryAddresses,
    );
  }

  static DockerIPAMConfig fromValues(Map<String, dynamic> data) {
    return DockerIPAMConfig(
      subnet: data['subnet'],
      ipRange: data['ipRange'],
      gateway: data['gateway'],
      auxiliaryAddresses: data['auxiliaryAddresses'] ?? const {},
    );
  }

  static DockerIPAMConfig fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        DockerIPAMConfig,
        data.runtimeType,
        name,
      );
    }
    return DockerIPAMConfig(
      subnet: $subnet.fromJson(
        data['Subnet'],
        name: DataCodec.childName(name, 'Subnet'),
      ),
      ipRange: $ipRange.fromJson(
        data['IPRange'],
        name: DataCodec.childName(name, 'IPRange'),
      ),
      gateway: $gateway.fromJson(
        data['Gateway'],
        name: DataCodec.childName(name, 'Gateway'),
      ),
      auxiliaryAddresses: $auxiliaryAddresses.fromJson(
        data['AuxiliaryAddresses'],
        name: DataCodec.childName(name, 'AuxiliaryAddresses'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerIPAMConfig;
    return {
      'Subnet': $subnet.toJson($$data.subnet),
      'IPRange': $ipRange.toJson($$data.ipRange),
      'Gateway': $gateway.toJson($$data.gateway),
      'AuxiliaryAddresses': $auxiliaryAddresses.toJson(
        $$data.auxiliaryAddresses,
      ),
    }..removeWhere((k, v) => v == null);
  }
}
