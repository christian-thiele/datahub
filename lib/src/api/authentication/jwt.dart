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

  JWT(super.token, {super.prefix = 'Bearer '})
      : header = _readHeader(token),
        payload = _readPayload(token),
        signature = _readSignature(token);

  factory JWT.create(
    Map<String, dynamic> header,
    Map<String, dynamic> payload,
    RSAPrivateKey key,
  ) {
    final encodedHeader = _stripPad(_jsonBase64.encode(header));
    final encodedPayload = _stripPad(_jsonBase64.encode(payload));
    final bodyPart = '$encodedHeader.$encodedPayload';
    final body = utf8.encode(bodyPart);
    final signer = Signer('SHA-256/RSA');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(key));
    final rsaSignature =
        signer.generateSignature(Uint8List.fromList(body)) as RSASignature;
    final signature = _stripPad(base64UrlEncode(rsaSignature.bytes));

    return JWT('$bodyPart.$signature');
  }

  /// Verify a signed JWT.
  ///
  /// It is highly recommended to provide the [issuer] param, which
  /// prevents this method from fetching openid-configuration from unknown /
  /// malicious sources.
  Future<void> verify({
    String? issuer,
    String? audience,
    RSAPublicKey? publicKey,
    KeyCache? cache,
  }) async {
    if (alg != 'RS256') {
      throw Exception('Unsupported signing algorithm "$alg".');
    }

    if (kid == null && publicKey == null) {
      throw Exception('Missing key id in token header.');
    }

    if (iss == null) {
      throw Exception('Missing issuer in token.');
    }

    if (issuer != null && iss != issuer) {
      throw Exception('Issuer mismatch.');
    }

    if (audience != null && aud != audience) {
      throw Exception('Audience mismatch.');
    }

    final key = publicKey ?? cache?.get(kid!) ?? await _fetchKey();
    if (kid != null) {
      cache?.store(kid!, key);
    }

    final body = utf8.encode(token.split('.').take(2).join('.'));
    final signer = Signer('SHA-256/RSA');
    signer.init(false, PublicKeyParameter<RSAPublicKey>(key));
    if (signer.verifySignature(
        Uint8List.fromList(body), RSASignature(signature))) {
      return;
    }

    throw Exception('Invalid signature.');
  }

  Future<RSAPublicKey> _fetchKey() async {
    if (iss == null) {
      throw Exception('Missing issuer in token.');
    }

    final issuerUri = Uri.parse(iss!);
    final issuerClient = await RestClient.connect(issuerUri);
    final openIdConfig = await issuerClient.getObject<Map<String, dynamic>>(
      '/.well-known/openid-configuration',
    )
      ..throwOnError();

    if (openIdConfig.data['issuer'] != iss) {
      throw Exception('Issuer mismatch in openid-configuration.');
    }

    if (openIdConfig.data['jwks_uri'] == null) {
      throw Exception('Missing JWKS uri in openid-configuration.');
    }

    final jwksUri = Uri.parse(openIdConfig.data['jwks_uri']);
    if (jwksUri.host != issuerUri.host) {
      throw Exception('JWKS uri host does not match issuer.');
    }

    final jwksRequest =
        await issuerClient.getObject<Map<String, dynamic>>(jwksUri.path)
          ..throwOnError();

    if (jwksRequest.data['keys'] is! List) {
      throw Exception('Invalid JWKS.');
    }

    for (final key in jwksRequest.data['keys']) {
      if (key['alg'] == alg && key['kid'] == kid) {
        if (key['n'] is String && key['e'] is String) {
          final n = _decodeBigInt(base64Decode(_base64Padded(key['n'])));
          final e = _decodeBigInt(base64Decode(_base64Padded(key['e'])));
          return RSAPublicKey(n, e);
        } else {
          throw Exception('Could not find e/n properties on key.');
        }
      }
    }

    throw Exception('Key not found in JWKS.');
  }

  static Map<String, dynamic> _readHeader(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT.');
    }
    return _jsonBase64.decode(_base64Padded(parts.first))
        as Map<String, dynamic>;
  }

  static Map<String, dynamic> _readPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT.');
    }
    return _jsonBase64.decode(_base64Padded(parts[1])) as Map<String, dynamic>;
  }

  static Uint8List _readSignature(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT.');
    }
    return base64Decode(_base64Padded(token.split('.')[2]));
  }

  static String _base64Padded(String value) {
    final length = value.length;
    final pad = length % 4;
    if (pad != 0) {
      return value.padRight(length + 4 - pad, '=');
    }
    return value;
  }

  static String _stripPad(String value) {
    return value.replaceAll(RegExp(r'=+$'), '');
  }

  static BigInt _decodeBigInt(List<int> bytes) {
    var result = BigInt.zero;
    for (var i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }
}
