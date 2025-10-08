// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_response.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $OidcResponse with DataObject<OidcResponse> {
  const $OidcResponse();
  static const $$codec = JsonDataCodec();
  static final $accessToken = DataField<OidcResponse, String>(
    name: 'accessToken',
    valueOf: (p) => p.accessToken,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $tokenType = DataField<OidcResponse, String>(
    name: 'tokenType',
    valueOf: (p) => p.tokenType,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $expiresIn = DataField<OidcResponse, int>(
    name: 'expiresIn',
    valueOf: (p) => p.expiresIn,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $scope = DataField<OidcResponse, String?>(
    name: 'scope',
    valueOf: (p) => p.scope,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $refreshToken = DataField<OidcResponse, String?>(
    name: 'refreshToken',
    valueOf: (p) => p.refreshToken,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $idToken = DataField<OidcResponse, String?>(
    name: 'idToken',
    valueOf: (p) => p.idToken,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<OidcResponse> bean = DataBean<OidcResponse>(
    name: 'OidcResponse',
    fields: List<DataField<OidcResponse, dynamic>>.unmodifiable([
      $accessToken,
      $tokenType,
      $expiresIn,
      $scope,
      $refreshToken,
      $idToken,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<OidcResponse, dynamic>> get $$fields => bean.fields;
  OidcResponse copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    String? scope,
    bool nullScope = false,
    String? refreshToken,
    bool nullRefreshToken = false,
    String? idToken,
    bool nullIdToken = false,
  }) {
    final $data = this as OidcResponse;
    return OidcResponse(
      accessToken: accessToken ?? $data.accessToken,
      tokenType: tokenType ?? $data.tokenType,
      expiresIn: expiresIn ?? $data.expiresIn,
      scope: nullScope ? null : (scope ?? $data.scope),
      refreshToken: nullRefreshToken
          ? null
          : (refreshToken ?? $data.refreshToken),
      idToken: nullIdToken ? null : (idToken ?? $data.idToken),
    );
  }

  static OidcResponse fromValues(Map<String, dynamic> data) {
    return OidcResponse(
      accessToken: data['accessToken'],
      tokenType: data['tokenType'],
      expiresIn: data['expiresIn'],
      scope: data['scope'],
      refreshToken: data['refreshToken'],
      idToken: data['idToken'],
    );
  }

  static OidcResponse fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(OidcResponse, data.runtimeType, name);
    }
    return OidcResponse(
      accessToken: $accessToken.fromJson(
        data['access_token'],
        name: DataCodec.childName(name, 'access_token'),
      ),
      tokenType: $tokenType.fromJson(
        data['token_type'],
        name: DataCodec.childName(name, 'token_type'),
      ),
      expiresIn: $expiresIn.fromJson(
        data['expires_in'],
        name: DataCodec.childName(name, 'expires_in'),
      ),
      scope: $scope.fromJson(
        data['scope'],
        name: DataCodec.childName(name, 'scope'),
      ),
      refreshToken: $refreshToken.fromJson(
        data['refresh_token'],
        name: DataCodec.childName(name, 'refresh_token'),
      ),
      idToken: $idToken.fromJson(
        data['id_token'],
        name: DataCodec.childName(name, 'id_token'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as OidcResponse;
    return {
      'access_token': $accessToken.toJson($$data.accessToken),
      'token_type': $tokenType.toJson($$data.tokenType),
      'expires_in': $expiresIn.toJson($$data.expiresIn),
      'scope': $scope.toJson($$data.scope),
      'refresh_token': $refreshToken.toJson($$data.refreshToken),
      'id_token': $idToken.toJson($$data.idToken),
    }..removeWhere((k, v) => v == null);
  }
}
