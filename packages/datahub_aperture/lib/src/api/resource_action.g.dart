// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_action.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceAction with DataObject<ResourceAction> {
  const $ResourceAction();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ResourceAction, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $displayName = DataField<ResourceAction, String>(
    name: 'displayName',
    valueOf: (p) => p.displayName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $icon = DataField<ResourceAction, int>(
    name: 'icon',
    valueOf: (p) => p.icon,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $parameterFields =
      DataField<ResourceAction, List<ResourceField>>(
    name: 'parameterFields',
    valueOf: (p) => p.parameterFields,
    dataBean: () => $ResourceField.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<ResourceField>(
        value, $ResourceField.bean.fromJson,
        name: name),
    toJson: (value) =>
        $$codec.encodeList<ResourceField>(value, (v) => v.toJson()),
  );

  static final DataBean<ResourceAction> bean = DataBean<ResourceAction>(
    name: 'ResourceAction',
    fields: List<DataField<ResourceAction, dynamic>>.unmodifiable([
      $id,
      $displayName,
      $icon,
      $parameterFields,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceAction, dynamic>> get $$fields => bean.fields;
  ResourceAction copyWith({
    String? id,
    String? displayName,
    int? icon,
    List<ResourceField>? parameterFields,
  }) {
    final $data = this as ResourceAction;
    return ResourceAction(
      id: id ?? $data.id,
      displayName: displayName ?? $data.displayName,
      icon: icon ?? $data.icon,
      parameterFields: parameterFields ?? $data.parameterFields,
    );
  }

  static ResourceAction fromValues(Map<String, dynamic> data) {
    return ResourceAction(
      id: data['id'],
      displayName: data['displayName'],
      icon: data['icon'],
      parameterFields: data['parameterFields'],
    );
  }

  static ResourceAction fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResourceAction, data.runtimeType, name);
    }
    return ResourceAction(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      displayName: $displayName.fromJson(data['displayName'],
          name: DataCodec.childName(name, 'displayName')),
      icon:
          $icon.fromJson(data['icon'], name: DataCodec.childName(name, 'icon')),
      parameterFields: $parameterFields.fromJson(data['parameterFields'],
          name: DataCodec.childName(name, 'parameterFields')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceAction;
    return {
      'id': $id.toJson($$data.id),
      'displayName': $displayName.toJson($$data.displayName),
      'icon': $icon.toJson($$data.icon),
      'parameterFields': $parameterFields.toJson($$data.parameterFields),
    }..removeWhere((k, v) => v == null);
  }
}
