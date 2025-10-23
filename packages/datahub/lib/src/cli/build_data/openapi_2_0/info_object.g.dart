// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $InfoObject with DataObject<InfoObject> {
  const $InfoObject();
  static const $$codec = JsonDataCodec();
  static final $title = DataField<InfoObject, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $description = DataField<InfoObject, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $termsOfService = DataField<InfoObject, String?>(
    name: 'termsOfService',
    valueOf: (p) => p.termsOfService,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $contact = DataField<InfoObject, ContactObject?>(
    name: 'contact',
    valueOf: (p) => p.contact,
    dataBean: () => $ContactObject.bean,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $ContactObject.bean.fromJson, name: name),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $license = DataField<InfoObject, LicenseObject?>(
    name: 'license',
    valueOf: (p) => p.license,
    dataBean: () => $LicenseObject.bean,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $LicenseObject.bean.fromJson, name: name),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $version = DataField<InfoObject, String>(
    name: 'version',
    valueOf: (p) => p.version,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<InfoObject> bean = DataBean<InfoObject>(
    name: 'InfoObject',
    fields: List<DataField<InfoObject, dynamic>>.unmodifiable([
      $title,
      $description,
      $termsOfService,
      $contact,
      $license,
      $version,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<InfoObject, dynamic>> get $$fields => bean.fields;
  InfoObject copyWith({
    String? title,
    String? description,
    bool nullDescription = false,
    String? termsOfService,
    bool nullTermsOfService = false,
    ContactObject? contact,
    bool nullContact = false,
    LicenseObject? license,
    bool nullLicense = false,
    String? version,
  }) {
    final $data = this as InfoObject;
    return InfoObject(
      title: title ?? $data.title,
      description: nullDescription ? null : (description ?? $data.description),
      termsOfService: nullTermsOfService
          ? null
          : (termsOfService ?? $data.termsOfService),
      contact: nullContact ? null : (contact ?? $data.contact),
      license: nullLicense ? null : (license ?? $data.license),
      version: version ?? $data.version,
    );
  }

  static InfoObject fromValues(Map<String, dynamic> data) {
    return InfoObject(
      title: data['title'],
      description: data['description'],
      termsOfService: data['termsOfService'],
      contact: data['contact'],
      license: data['license'],
      version: data['version'],
    );
  }

  static InfoObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(InfoObject, data.runtimeType, name);
    }
    return InfoObject(
      title: $title.fromJson(
        data['title'],
        name: DataCodec.childName(name, 'title'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      termsOfService: $termsOfService.fromJson(
        data['termsOfService'],
        name: DataCodec.childName(name, 'termsOfService'),
      ),
      contact: $contact.fromJson(
        data['contact'],
        name: DataCodec.childName(name, 'contact'),
      ),
      license: $license.fromJson(
        data['license'],
        name: DataCodec.childName(name, 'license'),
      ),
      version: $version.fromJson(
        data['version'],
        name: DataCodec.childName(name, 'version'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as InfoObject;
    return {
      'title': $title.toJson($$data.title),
      'description': $description.toJson($$data.description),
      'termsOfService': $termsOfService.toJson($$data.termsOfService),
      'contact': $contact.toJson($$data.contact),
      'license': $license.toJson($$data.license),
      'version': $version.toJson($$data.version),
    }..removeWhere((k, v) => v == null);
  }
}
