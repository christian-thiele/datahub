// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_auth_response.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $SimpleAuthResponse
    with DataObject<SimpleAuthResponse> {
  const $SimpleAuthResponse();
  static const $$codec = JsonDataCodec();
  static final $accessToken = DataField<SimpleAuthResponse, String>(
    name: 'accessToken',
    valueOf: (p) => p.accessToken,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $refreshToken = DataField<SimpleAuthResponse, String>(
    name: 'refreshToken',
    valueOf: (p) => p.refreshToken,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<SimpleAuthResponse> bean = DataBean<SimpleAuthResponse>(
    name: 'SimpleAuthResponse',
    fields: List<DataField<SimpleAuthResponse, dynamic>>.unmodifiable([
      $accessToken,
      $refreshToken,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<SimpleAuthResponse, dynamic>> get $$fields => bean.fields;
  SimpleAuthResponse copyWith({String? accessToken, String? refreshToken}) {
    final $data = this as SimpleAuthResponse;
    return SimpleAuthResponse(
      accessToken: accessToken ?? $data.accessToken,
      refreshToken: refreshToken ?? $data.refreshToken,
    );
  }

  static SimpleAuthResponse fromValues(Map<String, dynamic> data) {
    return SimpleAuthResponse(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  static SimpleAuthResponse fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        SimpleAuthResponse,
        data.runtimeType,
        name,
      );
    }
    return SimpleAuthResponse(
      accessToken: $accessToken.fromJson(
        data['accessToken'],
        name: DataCodec.childName(name, 'accessToken'),
      ),
      refreshToken: $refreshToken.fromJson(
        data['refreshToken'],
        name: DataCodec.childName(name, 'refreshToken'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as SimpleAuthResponse;
    return {
      'accessToken': $accessToken.toJson($$data.accessToken),
      'refreshToken': $refreshToken.toJson($$data.refreshToken),
    }..removeWhere((k, v) => v == null);
  }
}
