import 'dart:convert';

import 'package:pointycastle/pointycastle.dart';

import 'package:datahub/ioc.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/utils.dart';

import 'cache_key.dart';

/// This service provides a centralized cache for public keys.
///
/// Keys for JWT validation are often fetched from JSON Web Key Sets (JWKS).
/// Since key sets provide unique key-ids for every key, fetching the same key
/// over and over is not necessary when validating keys from the same issuer.
///
/// You can disable the key cache by setting the `datahub.enableKeyCache`
/// configuration value to false.
class KeyService extends BaseService {
  late final _enableCache = config<bool?>('enableKeyCache') ?? true;

  final _JWKCache = <CacheKey, RSAPublicKey>{};
  final _openIdCache = <Uri, Uri>{};

  KeyService() : super('datahub');

  /// Fetches the OAuth public key with id [kid] from [issuer].
  ///
  /// Keys are cached by default to avoid unnecessary requests.
  /// You can disable the key cache by setting the `datahub.enableKeyCache`
  /// configuration value to false.
  Future<RSAPublicKey> getOAuthKey(Uri issuer, String alg, String kid,
      {bool forceFetch = false}) async {
    if (_enableCache && !forceFetch && _openIdCache.containsKey(issuer)) {
      return await getJWKSKey(_openIdCache[issuer]!, alg, kid);
    }

    final issuerClient = await RestClient.connect(issuer);
    try {
      final issuerBasePath = issuer.path.endsWith('/')
          ? issuer.path.substring(0, issuer.path.length - 1)
          : issuer.path;
      final openIdConfig = await issuerClient.getObject<Map<String, dynamic>>(
        '$issuerBasePath/.well-known/openid-configuration',
      )
        ..throwOnError();

      if (Uri.tryParse(openIdConfig.data['issuer'])?.host != issuer.host) {
        throw Exception('Issuer mismatch in openid-configuration.');
      }

      if (openIdConfig.data['jwks_uri'] == null) {
        throw Exception('Missing JWKS uri in openid-configuration.');
      }

      final jwksUri = Uri.parse(openIdConfig.data['jwks_uri']);
      return await getJWKSKey(jwksUri, alg, kid);
    } finally {
      await issuerClient.close();
    }
  }

  Future<RSAPublicKey> getJWKSKey(Uri jwksUri, String alg, String kid,
      {bool forceFetch = false}) async {
    final cacheKey = CacheKey(jwksUri, alg, kid);
    if (_enableCache && !forceFetch && _JWKCache.containsKey(cacheKey)) {
      return _JWKCache[cacheKey]!;
    }

    final jwksClient = await RestClient.connect(jwksUri);
    try {
      final jwksRequest =
          await jwksClient.getObject<Map<String, dynamic>>(jwksUri.path)
            ..throwOnError();

      if (jwksRequest.data['keys'] is! List) {
        throw Exception('Invalid JWKS.');
      }

      for (final key in jwksRequest.data['keys']) {
        if (key['alg'] == alg && key['kid'] == kid) {
          if (key['n'] is String && key['e'] is String) {
            final n = _decodeBigInt(base64Decode(addBase64Padding(key['n'])));
            final e = _decodeBigInt(base64Decode(addBase64Padding(key['e'])));
            final pub = RSAPublicKey(n, e);
            if (_enableCache) {
              return _JWKCache[cacheKey] = pub;
            } else {
              return pub;
            }
          } else {
            throw Exception('Could not find e/n properties on key.');
          }
        }
      }
    } finally {
      await jwksClient.close();
    }

    throw Exception('Key not found in JWKS.');
  }

  /// Clear all caches.
  void clearCache() {
    _JWKCache.clear();
    _openIdCache.clear();
  }

  static BigInt _decodeBigInt(List<int> bytes) {
    var result = BigInt.zero;
    for (var i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }
}
