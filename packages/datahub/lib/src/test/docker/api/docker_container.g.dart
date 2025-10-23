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
