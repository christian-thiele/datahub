// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Client with DataObject<Client> {
  const $Client();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Client, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $name = DataField<Client, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $secret = DataField<Client, String?>(
    name: 'secret',
    valueOf: (p) => p.secret,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $redirectUris = DataField<Client, List<String>>(
    name: 'redirectUris',
    valueOf: (p) => p.redirectUris,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $enabled = DataField<Client, bool>(
    name: 'enabled',
    valueOf: (p) => p.enabled,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final DataBean<Client> bean = DataBean<Client>(
    name: 'Client',
    fields: List<DataField<Client, dynamic>>.unmodifiable([
      $id,
      $name,
      $secret,
      $redirectUris,
      $enabled,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Client, dynamic>> get $$fields => bean.fields;
  Client copyWith({
    String? id,
    String? name,
    String? secret,
    bool nullSecret = false,
    List<String>? redirectUris,
    bool? enabled,
  }) {
    final $data = this as Client;
    return Client(
      id: id ?? $data.id,
      name: name ?? $data.name,
      secret: nullSecret ? null : (secret ?? $data.secret),
      redirectUris: redirectUris ?? $data.redirectUris,
      enabled: enabled ?? $data.enabled,
    );
  }

  static Client fromValues(Map<String, dynamic> data) {
    return Client(
      id: data['id'],
      name: data['name'],
      secret: data['secret'],
      redirectUris: data['redirectUris']?.cast<String>().toList(
        growable: false,
      ),
      enabled: data['enabled'],
    );
  }

  static Client fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Client, data.runtimeType, name);
    }
    return Client(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      secret: $secret.fromJson(
        data['secret'],
        name: DataCodec.childName(name, 'secret'),
      ),
      redirectUris: $redirectUris.fromJson(
        data['redirectUris'],
        name: DataCodec.childName(name, 'redirectUris'),
      ),
      enabled: $enabled.fromJson(
        data['enabled'],
        name: DataCodec.childName(name, 'enabled'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Client;
    return {
      'id': $id.toJson($$data.id),
      'name': $name.toJson($$data.name),
      'secret': $secret.toJson($$data.secret),
      'redirectUris': $redirectUris.toJson($$data.redirectUris),
      'enabled': $enabled.toJson($$data.enabled),
    }..removeWhere((k, v) => v == null);
  }
}
