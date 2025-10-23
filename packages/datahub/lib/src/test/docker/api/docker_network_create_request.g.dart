// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_network_create_request.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerNetworkCreateRequest
    with DataObject<DockerNetworkCreateRequest> {
  const $DockerNetworkCreateRequest();
  static const $$codec = JsonDataCodec();
  static final $name = DataField<DockerNetworkCreateRequest, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $driver = DataField<DockerNetworkCreateRequest, String?>(
    name: 'driver',
    valueOf: (p) => p.driver,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $scope = DataField<DockerNetworkCreateRequest, String?>(
    name: 'scope',
    valueOf: (p) => p.scope,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $internal = DataField<DockerNetworkCreateRequest, bool?>(
    name: 'internal',
    valueOf: (p) => p.internal,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $attachable = DataField<DockerNetworkCreateRequest, bool?>(
    name: 'attachable',
    valueOf: (p) => p.attachable,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $ingress = DataField<DockerNetworkCreateRequest, bool?>(
    name: 'ingress',
    valueOf: (p) => p.ingress,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $configOnly = DataField<DockerNetworkCreateRequest, bool>(
    name: 'configOnly',
    valueOf: (p) => p.configOnly,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $configFrom =
      DataField<DockerNetworkCreateRequest, DockerConfigReference?>(
        name: 'configFrom',
        valueOf: (p) => p.configFrom,
        dataBean: () => $DockerConfigReference.bean,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          $DockerConfigReference.bean.fromJson,
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
      );

  static final $ipam = DataField<DockerNetworkCreateRequest, DockerIPAM?>(
    name: 'ipam',
    valueOf: (p) => p.ipam,
    dataBean: () => $DockerIPAM.bean,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $DockerIPAM.bean.fromJson, name: name),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $enableIPv4 = DataField<DockerNetworkCreateRequest, bool?>(
    name: 'enableIPv4',
    valueOf: (p) => p.enableIPv4,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $enableIPv6 = DataField<DockerNetworkCreateRequest, bool?>(
    name: 'enableIPv6',
    valueOf: (p) => p.enableIPv6,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $options =
      DataField<DockerNetworkCreateRequest, Map<String, String>>(
        name: 'options',
        valueOf: (p) => p.options,
        fromJson: (value, {String? name}) => $$codec.decodeMap<String>(
          (value ?? const {}),
          $$codec.decodeString,
          name: name,
        ),
        toJson: (value) =>
            $$codec.encodeMap<String>(value, $$codec.encodeString),
      );

  static final $labels =
      DataField<DockerNetworkCreateRequest, Map<String, String>>(
        name: 'labels',
        valueOf: (p) => p.labels,
        fromJson: (value, {String? name}) => $$codec.decodeMap<String>(
          (value ?? const {}),
          $$codec.decodeString,
          name: name,
        ),
        toJson: (value) =>
            $$codec.encodeMap<String>(value, $$codec.encodeString),
      );

  static final DataBean<DockerNetworkCreateRequest> bean =
      DataBean<DockerNetworkCreateRequest>(
        name: 'DockerNetworkCreateRequest',
        fields:
            List<DataField<DockerNetworkCreateRequest, dynamic>>.unmodifiable([
              $name,
              $driver,
              $scope,
              $internal,
              $attachable,
              $ingress,
              $configOnly,
              $configFrom,
              $ipam,
              $enableIPv4,
              $enableIPv6,
              $options,
              $labels,
            ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerNetworkCreateRequest, dynamic>> get $$fields =>
      bean.fields;
  DockerNetworkCreateRequest copyWith({
    String? name,
    String? driver,
    bool nullDriver = false,
    String? scope,
    bool nullScope = false,
    bool? internal,
    bool nullInternal = false,
    bool? attachable,
    bool nullAttachable = false,
    bool? ingress,
    bool nullIngress = false,
    bool? configOnly,
    DockerConfigReference? configFrom,
    bool nullConfigFrom = false,
    DockerIPAM? ipam,
    bool nullIpam = false,
    bool? enableIPv4,
    bool nullEnableIPv4 = false,
    bool? enableIPv6,
    bool nullEnableIPv6 = false,
    Map<String, String>? options,
    Map<String, String>? labels,
  }) {
    final $data = this as DockerNetworkCreateRequest;
    return DockerNetworkCreateRequest(
      name: name ?? $data.name,
      driver: nullDriver ? null : (driver ?? $data.driver),
      scope: nullScope ? null : (scope ?? $data.scope),
      internal: nullInternal ? null : (internal ?? $data.internal),
      attachable: nullAttachable ? null : (attachable ?? $data.attachable),
      ingress: nullIngress ? null : (ingress ?? $data.ingress),
      configOnly: configOnly ?? $data.configOnly,
      configFrom: nullConfigFrom ? null : (configFrom ?? $data.configFrom),
      ipam: nullIpam ? null : (ipam ?? $data.ipam),
      enableIPv4: nullEnableIPv4 ? null : (enableIPv4 ?? $data.enableIPv4),
      enableIPv6: nullEnableIPv6 ? null : (enableIPv6 ?? $data.enableIPv6),
      options: options ?? $data.options,
      labels: labels ?? $data.labels,
    );
  }

  static DockerNetworkCreateRequest fromValues(Map<String, dynamic> data) {
    return DockerNetworkCreateRequest(
      name: data['name'],
      driver: data['driver'],
      scope: data['scope'],
      internal: data['internal'],
      attachable: data['attachable'],
      ingress: data['ingress'],
      configOnly: data['configOnly'] ?? false,
      configFrom: data['configFrom'],
      ipam: data['ipam'],
      enableIPv4: data['enableIPv4'],
      enableIPv6: data['enableIPv6'],
      options: data['options'] ?? const {},
      labels: data['labels'] ?? const {},
    );
  }

  static DockerNetworkCreateRequest fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        DockerNetworkCreateRequest,
        data.runtimeType,
        name,
      );
    }
    return DockerNetworkCreateRequest(
      name: $name.fromJson(
        data['Name'],
        name: DataCodec.childName(name, 'Name'),
      ),
      driver: $driver.fromJson(
        data['Driver'],
        name: DataCodec.childName(name, 'Driver'),
      ),
      scope: $scope.fromJson(
        data['Scope'],
        name: DataCodec.childName(name, 'Scope'),
      ),
      internal: $internal.fromJson(
        data['Internal'],
        name: DataCodec.childName(name, 'Internal'),
      ),
      attachable: $attachable.fromJson(
        data['Attachable'],
        name: DataCodec.childName(name, 'Attachable'),
      ),
      ingress: $ingress.fromJson(
        data['Ingress'],
        name: DataCodec.childName(name, 'Ingress'),
      ),
      configOnly: $configOnly.fromJson(
        data['ConfigOnly'],
        name: DataCodec.childName(name, 'ConfigOnly'),
      ),
      configFrom: $configFrom.fromJson(
        data['ConfigFrom'],
        name: DataCodec.childName(name, 'ConfigFrom'),
      ),
      ipam: $ipam.fromJson(
        data['IPAM'],
        name: DataCodec.childName(name, 'IPAM'),
      ),
      enableIPv4: $enableIPv4.fromJson(
        data['EnableIPv4'],
        name: DataCodec.childName(name, 'EnableIPv4'),
      ),
      enableIPv6: $enableIPv6.fromJson(
        data['EnableIPv6'],
        name: DataCodec.childName(name, 'EnableIPv6'),
      ),
      options: $options.fromJson(
        data['Options'],
        name: DataCodec.childName(name, 'Options'),
      ),
      labels: $labels.fromJson(
        data['Labels'],
        name: DataCodec.childName(name, 'Labels'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerNetworkCreateRequest;
    return {
      'Name': $name.toJson($$data.name),
      'Driver': $driver.toJson($$data.driver),
      'Scope': $scope.toJson($$data.scope),
      'Internal': $internal.toJson($$data.internal),
      'Attachable': $attachable.toJson($$data.attachable),
      'Ingress': $ingress.toJson($$data.ingress),
      'ConfigOnly': $configOnly.toJson($$data.configOnly),
      'ConfigFrom': $configFrom.toJson($$data.configFrom),
      'IPAM': $ipam.toJson($$data.ipam),
      'EnableIPv4': $enableIPv4.toJson($$data.enableIPv4),
      'EnableIPv6': $enableIPv6.toJson($$data.enableIPv6),
      'Options': $options.toJson($$data.options),
      'Labels': $labels.toJson($$data.labels),
    }..removeWhere((k, v) => v == null);
  }
}
