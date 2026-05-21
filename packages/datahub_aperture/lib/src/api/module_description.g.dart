// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_description.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ModuleDescription with DataObject<ModuleDescription> {
  const $ModuleDescription();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ModuleDescription, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $displayName = DataField<ModuleDescription, String>(
    name: 'displayName',
    valueOf: (p) => p.displayName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $icon = DataField<ModuleDescription, int>(
    name: 'icon',
    valueOf: (p) => p.icon,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $type = DataField<ModuleDescription, ModuleType>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, ModuleType.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: ModuleType.values)],
  );

  static final $configuration =
      DataField<ModuleDescription, Map<String, dynamic>>(
        name: 'configuration',
        valueOf: (p) => p.configuration,
        fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
          value,
          $$codec.decodeDynamic,
          name: name,
        ),
        toJson: (value) =>
            $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
      );

  static final DataBean<ModuleDescription> bean = DataBean<ModuleDescription>(
    name: 'ModuleDescription',
    fields: List<DataField<ModuleDescription, dynamic>>.unmodifiable([
      $id,
      $displayName,
      $icon,
      $type,
      $configuration,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ModuleDescription, dynamic>> get $$fields => bean.fields;
  ModuleDescription copyWith({
    String? id,
    String? displayName,
    int? icon,
    ModuleType? type,
    Map<String, dynamic>? configuration,
  }) {
    final $data = this as ModuleDescription;
    return ModuleDescription(
      id: id ?? $data.id,
      displayName: displayName ?? $data.displayName,
      icon: icon ?? $data.icon,
      type: type ?? $data.type,
      configuration: configuration ?? $data.configuration,
    );
  }

  static ModuleDescription fromValues(Map<String, dynamic> data) {
    return ModuleDescription(
      id: data['id'],
      displayName: data['displayName'],
      icon: data['icon'],
      type: data['type'],
      configuration: data['configuration'],
    );
  }

  static ModuleDescription fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ModuleDescription,
        data.runtimeType,
        name,
      );
    }
    return ModuleDescription(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      displayName: $displayName.fromJson(
        data['displayName'],
        name: DataCodec.childName(name, 'displayName'),
      ),
      icon: $icon.fromJson(
        data['icon'],
        name: DataCodec.childName(name, 'icon'),
      ),
      type: $type.fromJson(
        data['type'],
        name: DataCodec.childName(name, 'type'),
      ),
      configuration: $configuration.fromJson(
        data['configuration'],
        name: DataCodec.childName(name, 'configuration'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ModuleDescription;
    return {
      'id': $id.toJson($$data.id),
      'displayName': $displayName.toJson($$data.displayName),
      'icon': $icon.toJson($$data.icon),
      'type': $type.toJson($$data.type),
      'configuration': $configuration.toJson($$data.configuration),
    }..removeWhere((k, v) => v == null);
  }
}
