// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_container.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $DockerContainer with DataObject<DockerContainer> {
  const $DockerContainer();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<DockerContainer, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $names = DataField<DockerContainer, List<String>>(
    name: 'names',
    valueOf: (p) => p.names,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $image = DataField<DockerContainer, String>(
    name: 'image',
    valueOf: (p) => p.image,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $imageId = DataField<DockerContainer, String>(
    name: 'imageId',
    valueOf: (p) => p.imageId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $command = DataField<DockerContainer, String>(
    name: 'command',
    valueOf: (p) => p.command,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $created = DataField<DockerContainer, int>(
    name: 'created',
    valueOf: (p) => p.created,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $ports = DataField<DockerContainer, List<DockerPort>>(
    name: 'ports',
    valueOf: (p) => p.ports,
    dataBean: () => $DockerPort.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<DockerPort>(
      value,
      $DockerPort.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<DockerPort>(value, (v) => v.toJson()),
  );

  static final $sizeRw = DataField<DockerContainer, int?>(
    name: 'sizeRw',
    valueOf: (p) => p.sizeRw,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $sizeRootFs = DataField<DockerContainer, int?>(
    name: 'sizeRootFs',
    valueOf: (p) => p.sizeRootFs,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $labels = DataField<DockerContainer, Map<String, String>>(
    name: 'labels',
    valueOf: (p) => p.labels,
    fromJson: (value, {String? name}) =>
        $$codec.decodeMap<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeMap<String>(value, $$codec.encodeString),
  );

  static final $state = DataField<DockerContainer, DockerContainerState>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, DockerContainerState.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: DockerContainerState.values)],
  );

  static final $status = DataField<DockerContainer, String>(
    name: 'status',
    valueOf: (p) => p.status,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $hostConfig = DataField<DockerContainer, DockerHostConfig>(
    name: 'hostConfig',
    valueOf: (p) => p.hostConfig,
    dataBean: () => $DockerHostConfig.bean,
    fromJson: (value, {String? name}) =>
        $DockerHostConfig.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final $networkSettings =
      DataField<DockerContainer, DockerNetworkSettings>(
        name: 'networkSettings',
        valueOf: (p) => p.networkSettings,
        dataBean: () => $DockerNetworkSettings.bean,
        fromJson: (value, {String? name}) =>
            $DockerNetworkSettings.bean.fromJson(value, name: name),
        toJson: (value) => value.toJson(),
      );

  static final $mounts = DataField<DockerContainer, List<DockerMountPoint>>(
    name: 'mounts',
    valueOf: (p) => p.mounts,
    dataBean: () => $DockerMountPoint.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<DockerMountPoint>(
      value,
      $DockerMountPoint.bean.fromJson,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<DockerMountPoint>(value, (v) => v.toJson()),
  );

  static final DataBean<DockerContainer> bean = DataBean<DockerContainer>(
    name: 'DockerContainer',
    fields: List<DataField<DockerContainer, dynamic>>.unmodifiable([
      $id,
      $names,
      $image,
      $imageId,
      $command,
      $created,
      $ports,
      $sizeRw,
      $sizeRootFs,
      $labels,
      $state,
      $status,
      $hostConfig,
      $networkSettings,
      $mounts,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<DockerContainer, dynamic>> get $$fields => bean.fields;
  DockerContainer copyWith({
    String? id,
    List<String>? names,
    String? image,
    String? imageId,
    String? command,
    int? created,
    List<DockerPort>? ports,
    int? sizeRw,
    bool nullSizeRw = false,
    int? sizeRootFs,
    bool nullSizeRootFs = false,
    Map<String, String>? labels,
    DockerContainerState? state,
    String? status,
    DockerHostConfig? hostConfig,
    DockerNetworkSettings? networkSettings,
    List<DockerMountPoint>? mounts,
  }) {
    final $data = this as DockerContainer;
    return DockerContainer(
      id: id ?? $data.id,
      names: names ?? $data.names,
      image: image ?? $data.image,
      imageId: imageId ?? $data.imageId,
      command: command ?? $data.command,
      created: created ?? $data.created,
      ports: ports ?? $data.ports,
      sizeRw: nullSizeRw ? null : (sizeRw ?? $data.sizeRw),
      sizeRootFs: nullSizeRootFs ? null : (sizeRootFs ?? $data.sizeRootFs),
      labels: labels ?? $data.labels,
      state: state ?? $data.state,
      status: status ?? $data.status,
      hostConfig: hostConfig ?? $data.hostConfig,
      networkSettings: networkSettings ?? $data.networkSettings,
      mounts: mounts ?? $data.mounts,
    );
  }

  static DockerContainer fromValues(Map<String, dynamic> data) {
    return DockerContainer(
      id: data['id'],
      names: data['names'],
      image: data['image'],
      imageId: data['imageId'],
      command: data['command'],
      created: data['created'],
      ports: data['ports'],
      sizeRw: data['sizeRw'],
      sizeRootFs: data['sizeRootFs'],
      labels: data['labels'],
      state: data['state'],
      status: data['status'],
      hostConfig: data['hostConfig'],
      networkSettings: data['networkSettings'],
      mounts: data['mounts'],
    );
  }

  static DockerContainer fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        DockerContainer,
        data.runtimeType,
        name,
      );
    }
    return DockerContainer(
      id: $id.fromJson(data['Id'], name: DataCodec.childName(name, 'Id')),
      names: $names.fromJson(
        data['Names'],
        name: DataCodec.childName(name, 'Names'),
      ),
      image: $image.fromJson(
        data['Image'],
        name: DataCodec.childName(name, 'Image'),
      ),
      imageId: $imageId.fromJson(
        data['ImageID'],
        name: DataCodec.childName(name, 'ImageID'),
      ),
      command: $command.fromJson(
        data['Command'],
        name: DataCodec.childName(name, 'Command'),
      ),
      created: $created.fromJson(
        data['Created'],
        name: DataCodec.childName(name, 'Created'),
      ),
      ports: $ports.fromJson(
        data['Ports'],
        name: DataCodec.childName(name, 'Ports'),
      ),
      sizeRw: $sizeRw.fromJson(
        data['SizeRw'],
        name: DataCodec.childName(name, 'SizeRw'),
      ),
      sizeRootFs: $sizeRootFs.fromJson(
        data['SizeRootFs'],
        name: DataCodec.childName(name, 'SizeRootFs'),
      ),
      labels: $labels.fromJson(
        data['Labels'],
        name: DataCodec.childName(name, 'Labels'),
      ),
      state: $state.fromJson(
        data['State'],
        name: DataCodec.childName(name, 'State'),
      ),
      status: $status.fromJson(
        data['Status'],
        name: DataCodec.childName(name, 'Status'),
      ),
      hostConfig: $hostConfig.fromJson(
        data['HostConfig'],
        name: DataCodec.childName(name, 'HostConfig'),
      ),
      networkSettings: $networkSettings.fromJson(
        data['NetworkSettings'],
        name: DataCodec.childName(name, 'NetworkSettings'),
      ),
      mounts: $mounts.fromJson(
        data['Mounts'],
        name: DataCodec.childName(name, 'Mounts'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as DockerContainer;
    return {
      'Id': $id.toJson($$data.id),
      'Names': $names.toJson($$data.names),
      'Image': $image.toJson($$data.image),
      'ImageID': $imageId.toJson($$data.imageId),
      'Command': $command.toJson($$data.command),
      'Created': $created.toJson($$data.created),
      'Ports': $ports.toJson($$data.ports),
      'SizeRw': $sizeRw.toJson($$data.sizeRw),
      'SizeRootFs': $sizeRootFs.toJson($$data.sizeRootFs),
      'Labels': $labels.toJson($$data.labels),
      'State': $state.toJson($$data.state),
      'Status': $status.toJson($$data.status),
      'HostConfig': $hostConfig.toJson($$data.hostConfig),
      'NetworkSettings': $networkSettings.toJson($$data.networkSettings),
      'Mounts': $mounts.toJson($$data.mounts),
    }..removeWhere((k, v) => v == null);
  }
}

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
