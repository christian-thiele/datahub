import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:pointycastle/pointycastle.dart';

class JWT extends BearerAuth {
  static final _jsonBase64 = json.fuse(utf8.fuse(base64Url));

  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
  final Uint8List signature;

  String? get alg => header['alg'];

  String? get kid => header['kid'];

  String? get iss => payload['iss'];

  String? get aud => payload['aud'];

  DateTime? get iat => payload['iat'] == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch((payload['iat'] as int) * 1000);

  DateTime? get exp => payload['exp'] == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch((payload['exp'] as int) * 1000);

  JWT(super.token, {super.prefix = 'Bearer '})
      : header = _readHeader(token),
        payload = _readPayload(token),
        signature = _readSignature(token);

  factory JWT.create(
    Map<String, dynamic> header,
    Map<String, dynamic> payload,
    RSAPrivateKey key,
  ) {
    final encodedHeader = stripBase64Padding(_jsonBase64.encode(header));
    final encodedPayload = stripBase64Padding(_jsonBase64.encode(payload));
    final bodyPart = '$encodedHeader.$encodedPayload';
    final body = utf8.encode(bodyPart);
    final signer = Signer('SHA-256/RSA');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(key));
    final rsaSignature =
        signer.generateSignature(Uint8List.fromList(body)) as RSASignature;
    final signature = stripBase64Padding(base64UrlEncode(rsaSignature.bytes));

    return JWT('$bodyPart.$signature');
  }

  /// Verify a signed JWT.
  ///
  /// It is highly recommended to provide the [issuer] param, which
  /// prevents this method from fetching openid-configuration from unknown /
  /// malicious sources.
  ///
  /// All of the following conditions must be true or else
  /// this method will throw:
  ///   - iat (issued at) must be before now
  ///   - exp (expiration) must be after now
  ///   - kid (key id) must be set or [publicKey] must be non-null
  ///   - iss (issuer) must be set
  ///   - [issuer] must be null or equal to iss
  ///   - [audience] must be null or equal to aud
  ///   - signature must be valid
  ///
  /// The key signature is checked either against the given [publicKey], or
  /// the key that is provided by the issuers JWKS.
  /// JWKS keys are usually cached by [KeyService].
  Future<void> verify({
    String? issuer,
    String? audience,
    RSAPublicKey? publicKey,
  }) async {
    if (alg != 'RS256') {
      throw ApiRequestException.unauthorized(
          'Unsupported signing algorithm "$alg".');
    }

    if (iat?.isAfter(DateTime.now()) == true) {
      throw ApiRequestException.unauthorized('Invalid issue timestamp.');
    }

    if (exp?.isBefore(DateTime.now()) == true) {
      throw ApiRequestException.unauthorized('Token expired.');
    }

    if (kid == null && publicKey == null) {
      throw ApiRequestException.unauthorized('Missing key id in token header.');
    }

    if (iss == null) {
      throw ApiRequestException.unauthorized('Missing issuer in token.');
    }

    if (issuer != null && iss != issuer) {
      throw ApiRequestException.unauthorized('Issuer mismatch.');
    }

    if (audience != null && aud != audience) {
      throw ApiRequestException.unauthorized('Audience mismatch.');
    }

    final key = publicKey ??
        await resolve<KeyService>().getKey(Uri.parse(iss!), alg!, kid!);

    final body = utf8.encode(token.split('.').take(2).join('.'));
    final signer = Signer('SHA-256/RSA');
    signer.init(false, PublicKeyParameter<RSAPublicKey>(key));
    if (signer.verifySignature(
        Uint8List.fromList(body), RSASignature(signature))) {
      return;
    }

    throw ApiRequestException.unauthorized('Invalid signature.');
  }

  static Map<String, dynamic> _readHeader(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw ApiRequestException.unauthorized('Invalid JWT.');
    }
    return _jsonBase64.decode(addBase64Padding(parts.first))
        as Map<String, dynamic>;
  }

  static Map<String, dynamic> _readPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw ApiRequestException.unauthorized('Invalid JWT.');
    }
    return _jsonBase64.decode(addBase64Padding(parts[1]))
        as Map<String, dynamic>;
  }

  static Uint8List _readSignature(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw ApiRequestException.unauthorized('Invalid JWT.');
    }
    return base64Decode(addBase64Padding(token.split('.')[2]));
  }
}
