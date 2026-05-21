// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwk.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Jwk with DataObject<Jwk> {
  const $Jwk();
  static const $$codec = JsonDataCodec();
  static final $keyType = DataField<Jwk, String>(
    name: 'keyType',
    valueOf: (p) => p.keyType,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $publicKeyUse = DataField<Jwk, String?>(
    name: 'publicKeyUse',
    valueOf: (p) => p.publicKeyUse,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $keyOperations = DataField<Jwk, String?>(
    name: 'keyOperations',
    valueOf: (p) => p.keyOperations,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $algorithm = DataField<Jwk, String?>(
    name: 'algorithm',
    valueOf: (p) => p.algorithm,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $keyId = DataField<Jwk, String?>(
    name: 'keyId',
    valueOf: (p) => p.keyId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $x509Url = DataField<Jwk, String?>(
    name: 'x509Url',
    valueOf: (p) => p.x509Url,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $x509CertificateChain = DataField<Jwk, String?>(
    name: 'x509CertificateChain',
    valueOf: (p) => p.x509CertificateChain,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $x509CertificateSha1Thumbprint = DataField<Jwk, String?>(
    name: 'x509CertificateSha1Thumbprint',
    valueOf: (p) => p.x509CertificateSha1Thumbprint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $x509CertificateSha256Thumbprint = DataField<Jwk, String?>(
    name: 'x509CertificateSha256Thumbprint',
    valueOf: (p) => p.x509CertificateSha256Thumbprint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $ecCurve = DataField<Jwk, String?>(
    name: 'ecCurve',
    valueOf: (p) => p.ecCurve,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $ecX = DataField<Jwk, String?>(
    name: 'ecX',
    valueOf: (p) => p.ecX,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $ecY = DataField<Jwk, String?>(
    name: 'ecY',
    valueOf: (p) => p.ecY,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $rsaModulus = DataField<Jwk, String?>(
    name: 'rsaModulus',
    valueOf: (p) => p.rsaModulus,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $rsaExponent = DataField<Jwk, String?>(
    name: 'rsaExponent',
    valueOf: (p) => p.rsaExponent,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<Jwk> bean = DataBean<Jwk>(
    name: 'Jwk',
    fields: List<DataField<Jwk, dynamic>>.unmodifiable([
      $keyType,
      $publicKeyUse,
      $keyOperations,
      $algorithm,
      $keyId,
      $x509Url,
      $x509CertificateChain,
      $x509CertificateSha1Thumbprint,
      $x509CertificateSha256Thumbprint,
      $ecCurve,
      $ecX,
      $ecY,
      $rsaModulus,
      $rsaExponent,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Jwk, dynamic>> get $$fields => bean.fields;
  Jwk copyWith({
    String? keyType,
    String? publicKeyUse,
    bool nullPublicKeyUse = false,
    String? keyOperations,
    bool nullKeyOperations = false,
    String? algorithm,
    bool nullAlgorithm = false,
    String? keyId,
    bool nullKeyId = false,
    String? x509Url,
    bool nullX509Url = false,
    String? x509CertificateChain,
    bool nullX509CertificateChain = false,
    String? x509CertificateSha1Thumbprint,
    bool nullX509CertificateSha1Thumbprint = false,
    String? x509CertificateSha256Thumbprint,
    bool nullX509CertificateSha256Thumbprint = false,
    String? ecCurve,
    bool nullEcCurve = false,
    String? ecX,
    bool nullEcX = false,
    String? ecY,
    bool nullEcY = false,
    String? rsaModulus,
    bool nullRsaModulus = false,
    String? rsaExponent,
    bool nullRsaExponent = false,
  }) {
    final $data = this as Jwk;
    return Jwk(
      keyType: keyType ?? $data.keyType,
      publicKeyUse: nullPublicKeyUse
          ? null
          : (publicKeyUse ?? $data.publicKeyUse),
      keyOperations: nullKeyOperations
          ? null
          : (keyOperations ?? $data.keyOperations),
      algorithm: nullAlgorithm ? null : (algorithm ?? $data.algorithm),
      keyId: nullKeyId ? null : (keyId ?? $data.keyId),
      x509Url: nullX509Url ? null : (x509Url ?? $data.x509Url),
      x509CertificateChain: nullX509CertificateChain
          ? null
          : (x509CertificateChain ?? $data.x509CertificateChain),
      x509CertificateSha1Thumbprint: nullX509CertificateSha1Thumbprint
          ? null
          : (x509CertificateSha1Thumbprint ??
                $data.x509CertificateSha1Thumbprint),
      x509CertificateSha256Thumbprint: nullX509CertificateSha256Thumbprint
          ? null
          : (x509CertificateSha256Thumbprint ??
                $data.x509CertificateSha256Thumbprint),
      ecCurve: nullEcCurve ? null : (ecCurve ?? $data.ecCurve),
      ecX: nullEcX ? null : (ecX ?? $data.ecX),
      ecY: nullEcY ? null : (ecY ?? $data.ecY),
      rsaModulus: nullRsaModulus ? null : (rsaModulus ?? $data.rsaModulus),
      rsaExponent: nullRsaExponent ? null : (rsaExponent ?? $data.rsaExponent),
    );
  }

  static Jwk fromValues(Map<String, dynamic> data) {
    return Jwk(
      keyType: data['keyType'],
      publicKeyUse: data['publicKeyUse'],
      keyOperations: data['keyOperations'],
      algorithm: data['algorithm'],
      keyId: data['keyId'],
      x509Url: data['x509Url'],
      x509CertificateChain: data['x509CertificateChain'],
      x509CertificateSha1Thumbprint: data['x509CertificateSha1Thumbprint'],
      x509CertificateSha256Thumbprint: data['x509CertificateSha256Thumbprint'],
      ecCurve: data['ecCurve'],
      ecX: data['ecX'],
      ecY: data['ecY'],
      rsaModulus: data['rsaModulus'],
      rsaExponent: data['rsaExponent'],
    );
  }

  static Jwk fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Jwk, data.runtimeType, name);
    }
    return Jwk(
      keyType: $keyType.fromJson(
        data['kty'],
        name: DataCodec.childName(name, 'kty'),
      ),
      publicKeyUse: $publicKeyUse.fromJson(
        data['use'],
        name: DataCodec.childName(name, 'use'),
      ),
      keyOperations: $keyOperations.fromJson(
        data['key_ops'],
        name: DataCodec.childName(name, 'key_ops'),
      ),
      algorithm: $algorithm.fromJson(
        data['alg'],
        name: DataCodec.childName(name, 'alg'),
      ),
      keyId: $keyId.fromJson(
        data['kid'],
        name: DataCodec.childName(name, 'kid'),
      ),
      x509Url: $x509Url.fromJson(
        data['x5u'],
        name: DataCodec.childName(name, 'x5u'),
      ),
      x509CertificateChain: $x509CertificateChain.fromJson(
        data['x5c'],
        name: DataCodec.childName(name, 'x5c'),
      ),
      x509CertificateSha1Thumbprint: $x509CertificateSha1Thumbprint.fromJson(
        data['x5t'],
        name: DataCodec.childName(name, 'x5t'),
      ),
      x509CertificateSha256Thumbprint: $x509CertificateSha256Thumbprint
          .fromJson(
            data['x5t#S256'],
            name: DataCodec.childName(name, 'x5t#S256'),
          ),
      ecCurve: $ecCurve.fromJson(
        data['crv'],
        name: DataCodec.childName(name, 'crv'),
      ),
      ecX: $ecX.fromJson(data['x'], name: DataCodec.childName(name, 'x')),
      ecY: $ecY.fromJson(data['y'], name: DataCodec.childName(name, 'y')),
      rsaModulus: $rsaModulus.fromJson(
        data['n'],
        name: DataCodec.childName(name, 'n'),
      ),
      rsaExponent: $rsaExponent.fromJson(
        data['e'],
        name: DataCodec.childName(name, 'e'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Jwk;
    return {
      'kty': $keyType.toJson($$data.keyType),
      'use': $publicKeyUse.toJson($$data.publicKeyUse),
      'key_ops': $keyOperations.toJson($$data.keyOperations),
      'alg': $algorithm.toJson($$data.algorithm),
      'kid': $keyId.toJson($$data.keyId),
      'x5u': $x509Url.toJson($$data.x509Url),
      'x5c': $x509CertificateChain.toJson($$data.x509CertificateChain),
      'x5t': $x509CertificateSha1Thumbprint.toJson(
        $$data.x509CertificateSha1Thumbprint,
      ),
      'x5t#S256': $x509CertificateSha256Thumbprint.toJson(
        $$data.x509CertificateSha256Thumbprint,
      ),
      'crv': $ecCurve.toJson($$data.ecCurve),
      'x': $ecX.toJson($$data.ecX),
      'y': $ecY.toJson($$data.ecY),
      'n': $rsaModulus.toJson($$data.rsaModulus),
      'e': $rsaExponent.toJson($$data.rsaExponent),
    }..removeWhere((k, v) => v == null);
  }
}
