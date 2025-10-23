// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ContactObject with DataObject<ContactObject> {
  const $ContactObject();
  static const $$codec = JsonDataCodec();
  static final $name = DataField<ContactObject, String?>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $url = DataField<ContactObject, String?>(
    name: 'url',
    valueOf: (p) => p.url,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $email = DataField<ContactObject, String?>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<ContactObject> bean = DataBean<ContactObject>(
    name: 'ContactObject',
    fields: List<DataField<ContactObject, dynamic>>.unmodifiable([
      $name,
      $url,
      $email,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ContactObject, dynamic>> get $$fields => bean.fields;
  ContactObject copyWith({
    String? name,
    bool nullName = false,
    String? url,
    bool nullUrl = false,
    String? email,
    bool nullEmail = false,
  }) {
    final $data = this as ContactObject;
    return ContactObject(
      name: nullName ? null : (name ?? $data.name),
      url: nullUrl ? null : (url ?? $data.url),
      email: nullEmail ? null : (email ?? $data.email),
    );
  }

  static ContactObject fromValues(Map<String, dynamic> data) {
    return ContactObject(
      name: data['name'],
      url: data['url'],
      email: data['email'],
    );
  }

  static ContactObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ContactObject, data.runtimeType, name);
    }
    return ContactObject(
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      url: $url.fromJson(data['url'], name: DataCodec.childName(name, 'url')),
      email: $email.fromJson(
        data['email'],
        name: DataCodec.childName(name, 'email'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ContactObject;
    return {
      'name': $name.toJson($$data.name),
      'url': $url.toJson($$data.url),
      'email': $email.toJson($$data.email),
    }..removeWhere((k, v) => v == null);
  }
}
