// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_auth_refresh_request.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $SimpleAuthRefreshRequest
    with DataObject<SimpleAuthRefreshRequest> {
  const $SimpleAuthRefreshRequest();
  static const $$codec = JsonDataCodec();
  static final $refreshToken = DataField<SimpleAuthRefreshRequest, String>(
    name: 'refreshToken',
    valueOf: (p) => p.refreshToken,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<SimpleAuthRefreshRequest> bean =
      DataBean<SimpleAuthRefreshRequest>(
    name: 'SimpleAuthRefreshRequest',
    fields: List<DataField<SimpleAuthRefreshRequest, dynamic>>.unmodifiable([
      $refreshToken,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<SimpleAuthRefreshRequest, dynamic>> get $$fields =>
      bean.fields;
  SimpleAuthRefreshRequest copyWith({
    String? refreshToken,
  }) {
    final $data = this as SimpleAuthRefreshRequest;
    return SimpleAuthRefreshRequest(
      refreshToken: refreshToken ?? $data.refreshToken,
    );
  }

  static SimpleAuthRefreshRequest fromValues(Map<String, dynamic> data) {
    return SimpleAuthRefreshRequest(
      refreshToken: data['refreshToken'],
    );
  }

  static SimpleAuthRefreshRequest fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          SimpleAuthRefreshRequest, data.runtimeType, name);
    }
    return SimpleAuthRefreshRequest(
      refreshToken: $refreshToken.fromJson(data['refreshToken'],
          name: DataCodec.childName(name, 'refreshToken')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as SimpleAuthRefreshRequest;
    return {
      'refreshToken': $refreshToken.toJson($$data.refreshToken),
    }..removeWhere((k, v) => v == null);
  }
}
