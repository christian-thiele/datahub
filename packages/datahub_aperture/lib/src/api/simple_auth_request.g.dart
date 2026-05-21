// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_auth_request.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $SimpleAuthRequest with DataObject<SimpleAuthRequest> {
  const $SimpleAuthRequest();
  static const $$codec = JsonDataCodec();
  static final $username = DataField<SimpleAuthRequest, String>(
    name: 'username',
    valueOf: (p) => p.username,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $password = DataField<SimpleAuthRequest, String>(
    name: 'password',
    valueOf: (p) => p.password,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<SimpleAuthRequest> bean = DataBean<SimpleAuthRequest>(
    name: 'SimpleAuthRequest',
    fields: List<DataField<SimpleAuthRequest, dynamic>>.unmodifiable([
      $username,
      $password,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<SimpleAuthRequest, dynamic>> get $$fields => bean.fields;
  SimpleAuthRequest copyWith({String? username, String? password}) {
    final $data = this as SimpleAuthRequest;
    return SimpleAuthRequest(
      username: username ?? $data.username,
      password: password ?? $data.password,
    );
  }

  static SimpleAuthRequest fromValues(Map<String, dynamic> data) {
    return SimpleAuthRequest(
      username: data['username'],
      password: data['password'],
    );
  }

  static SimpleAuthRequest fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        SimpleAuthRequest,
        data.runtimeType,
        name,
      );
    }
    return SimpleAuthRequest(
      username: $username.fromJson(
        data['username'],
        name: DataCodec.childName(name, 'username'),
      ),
      password: $password.fromJson(
        data['password'],
        name: DataCodec.childName(name, 'password'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as SimpleAuthRequest;
    return {
      'username': $username.toJson($$data.username),
      'password': $password.toJson($$data.password),
    }..removeWhere((k, v) => v == null);
  }
}
