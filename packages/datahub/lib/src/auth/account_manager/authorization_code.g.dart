// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_code.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $AuthorizationCode with DataObject<AuthorizationCode> {
  const $AuthorizationCode();
  static const $$codec = JsonDataCodec();
  static final $code = DataField<AuthorizationCode, String>(
    name: 'code',
    valueOf: (p) => p.code,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id()],
  );

  static final $clientId = DataField<AuthorizationCode, String>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $challenge = DataField<AuthorizationCode, String>(
    name: 'challenge',
    valueOf: (p) => p.challenge,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $state = DataField<AuthorizationCode, String>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $issuedAt = DataField<AuthorizationCode, DateTime>(
    name: 'issuedAt',
    valueOf: (p) => p.issuedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $validUntil = DataField<AuthorizationCode, DateTime>(
    name: 'validUntil',
    valueOf: (p) => p.validUntil,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final DataBean<AuthorizationCode> bean = DataBean<AuthorizationCode>(
    name: 'AuthorizationCode',
    fields: List<DataField<AuthorizationCode, dynamic>>.unmodifiable([
      $code,
      $clientId,
      $challenge,
      $state,
      $issuedAt,
      $validUntil,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<AuthorizationCode, dynamic>> get $$fields => bean.fields;
  AuthorizationCode copyWith({
    String? code,
    String? clientId,
    String? challenge,
    String? state,
    DateTime? issuedAt,
    DateTime? validUntil,
  }) {
    final $data = this as AuthorizationCode;
    return AuthorizationCode(
      code: code ?? $data.code,
      clientId: clientId ?? $data.clientId,
      challenge: challenge ?? $data.challenge,
      state: state ?? $data.state,
      issuedAt: issuedAt ?? $data.issuedAt,
      validUntil: validUntil ?? $data.validUntil,
    );
  }

  static AuthorizationCode fromValues(Map<String, dynamic> data) {
    return AuthorizationCode(
      code: data['code'],
      clientId: data['clientId'],
      challenge: data['challenge'],
      state: data['state'],
      issuedAt: data['issuedAt'],
      validUntil: data['validUntil'],
    );
  }

  static AuthorizationCode fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        AuthorizationCode,
        data.runtimeType,
        name,
      );
    }
    return AuthorizationCode(
      code: $code.fromJson(
        data['code'],
        name: DataCodec.childName(name, 'code'),
      ),
      clientId: $clientId.fromJson(
        data['clientId'],
        name: DataCodec.childName(name, 'clientId'),
      ),
      challenge: $challenge.fromJson(
        data['challenge'],
        name: DataCodec.childName(name, 'challenge'),
      ),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
      issuedAt: $issuedAt.fromJson(
        data['issuedAt'],
        name: DataCodec.childName(name, 'issuedAt'),
      ),
      validUntil: $validUntil.fromJson(
        data['validUntil'],
        name: DataCodec.childName(name, 'validUntil'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as AuthorizationCode;
    return {
      'code': $code.toJson($$data.code),
      'clientId': $clientId.toJson($$data.clientId),
      'challenge': $challenge.toJson($$data.challenge),
      'state': $state.toJson($$data.state),
      'issuedAt': $issuedAt.toJson($$data.issuedAt),
      'validUntil': $validUntil.toJson($$data.validUntil),
    }..removeWhere((k, v) => v == null);
  }
}
