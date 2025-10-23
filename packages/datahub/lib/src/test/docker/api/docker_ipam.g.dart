// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_ipam.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerIPAM with DataObject<DockerIPAM> {
  const $DockerIPAM();
  static const $$codec = JsonDataCodec();
  static final $driver = DataField<DockerIPAM, String?>(
    name: 'driver',
    valueOf: (p) => p.driver,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $config = DataField<DockerIPAM, List<DockerIPAMConfig>>(
    name: 'config',
    valueOf: (p) => p.config,
    dataBean: () => $DockerIPAMConfig.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<DockerIPAMConfig>(
      (value ?? const []),
      $DockerIPAMConfig.bean.fromJson,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<DockerIPAMConfig>(value, (v) => v.toJson()),
  );

  static final $options = DataField<DockerIPAM, Map<String, String>>(
    name: 'options',
    valueOf: (p) => p.options,
    fromJson: (value, {String? name}) => $$codec.decodeMap<String>(
      (value ?? const {}),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeMap<String>(value, $$codec.encodeString),
  );

  static final DataBean<DockerIPAM> bean = DataBean<DockerIPAM>(
    name: 'DockerIPAM',
    fields: List<DataField<DockerIPAM, dynamic>>.unmodifiable([
      $driver,
      $config,
      $options,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerIPAM, dynamic>> get $$fields => bean.fields;
  DockerIPAM copyWith({
    String? driver,
    bool nullDriver = false,
    List<DockerIPAMConfig>? config,
    Map<String, String>? options,
  }) {
    final $data = this as DockerIPAM;
    return DockerIPAM(
      driver: nullDriver ? null : (driver ?? $data.driver),
      config: config ?? $data.config,
      options: options ?? $data.options,
    );
  }

  static DockerIPAM fromValues(Map<String, dynamic> data) {
    return DockerIPAM(
      driver: data['driver'],
      config: data['config'] ?? const [],
      options: data['options'] ?? const {},
    );
  }

  static DockerIPAM fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(DockerIPAM, data.runtimeType, name);
    }
    return DockerIPAM(
      driver: $driver.fromJson(
        data['Driver'],
        name: DataCodec.childName(name, 'Driver'),
      ),
      config: $config.fromJson(
        data['Config'],
        name: DataCodec.childName(name, 'Config'),
      ),
      options: $options.fromJson(
        data['Options'],
        name: DataCodec.childName(name, 'Options'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerIPAM;
    return {
      'Driver': $driver.toJson($$data.driver),
      'Config': $config.toJson($$data.config),
      'Options': $options.toJson($$data.options),
    }..removeWhere((k, v) => v == null);
  }
}
