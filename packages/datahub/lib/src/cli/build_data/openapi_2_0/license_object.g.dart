// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $LicenseObject with DataObject<LicenseObject> {
  const $LicenseObject();
  static const $$codec = JsonDataCodec();
  static final $name = DataField<LicenseObject, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $url = DataField<LicenseObject, String?>(
    name: 'url',
    valueOf: (p) => p.url,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<LicenseObject> bean = DataBean<LicenseObject>(
    name: 'LicenseObject',
    fields: List<DataField<LicenseObject, dynamic>>.unmodifiable([$name, $url]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<LicenseObject, dynamic>> get $$fields => bean.fields;
  LicenseObject copyWith({String? name, String? url, bool nullUrl = false}) {
    final $data = this as LicenseObject;
    return LicenseObject(
      name: name ?? $data.name,
      url: nullUrl ? null : (url ?? $data.url),
    );
  }

  static LicenseObject fromValues(Map<String, dynamic> data) {
    return LicenseObject(name: data['name'], url: data['url']);
  }

  static LicenseObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(LicenseObject, data.runtimeType, name);
    }
    return LicenseObject(
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      url: $url.fromJson(data['url'], name: DataCodec.childName(name, 'url')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as LicenseObject;
    return {'name': $name.toJson($$data.name), 'url': $url.toJson($$data.url)}
      ..removeWhere((k, v) => v == null);
  }
}
