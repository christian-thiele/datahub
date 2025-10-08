import 'dart:convert';

import 'package:datahub/config.dart';
import 'package:pointycastle/pointycastle.dart';

import 'package:datahub/rest_client.dart';
import 'package:datahub/utils.dart';

import 'cache_key.dart';

import 'dart:async';
import 'package:datahub/scaffold.dart';

/// This service provides a centralized cache for public keys.
///
/// Keys for JWT validation are often fetched from JSON Web Key Sets (JWKS).
/// Since key sets provide unique key-ids for every key, fetching the same key
/// over and over is not necessary when validating keys from the same issuer.
abstract interface class KeyCache {
  /// Fetches the OAuth public key with id [kid] from [issuer].
  ///
  /// Keys are cached by default to avoid unnecessary requests.
  /// You can disable the key cache by setting the `datahub.enableKeyCache`
  /// configuration value to false.
  Future<RSAPublicKey> getOAuthKey(
    Uri issuer,
    String alg,
    String kid, {
    bool forceFetch = false,
  });

  Future<RSAPublicKey> getJwksKey(
    Uri jwksUri,
    String alg,
    String kid, {
    bool forceFetch = false,
  });

  void clearCache();
}

class KeyService implements Service {
  final Config<bool> enable;

  KeyService({
    this.enable = const Config('enableKeyCache', defaultValue: true),
  });

  @override
  ServiceInstance<KeyService> createInstance() => _KeyServiceInstance();
}

class _KeyServiceInstance extends ServiceInstance<KeyService>
    implements KeyCache {
  final _jwkCache = <CacheKey, RSAPublicKey>{};
  final _openIdCache = <Uri, Uri>{};

  @override
  Future<RSAPublicKey> getOAuthKey(
    Uri issuer,
    String alg,
    String kid, {
    bool forceFetch = false,
  }) async {
    if (read(service.enable) &&
        !forceFetch &&
        _openIdCache.containsKey(issuer)) {
      return await getJwksKey(_openIdCache[issuer]!, alg, kid);
    }

    final issuerClient = await RestClient.connect(issuer);
    try {
      final openIdConfig = await issuerClient
          .get('/.well-known/openid-configuration')
          .thenGetJsonBody();

      if (Uri.tryParse(openIdConfig['issuer'])?.host != issuer.host) {
        throw Exception('Issuer mismatch in openid-configuration.');
      }

      if (openIdConfig['jwks_uri'] == null) {
        throw Exception('Missing JWKS uri in openid-configuration.');
      }

      final jwksUri = Uri.parse(openIdConfig['jwks_uri']);
      return await getJwksKey(jwksUri, alg, kid);
    } finally {
      await issuerClient.close();
    }
  }

  @override
  Future<RSAPublicKey> getJwksKey(
    Uri jwksUri,
    String alg,
    String kid, {
    bool forceFetch = false,
  }) async {
    final cacheKey = CacheKey(jwksUri, alg, kid);
    if (read(service.enable) &&
        !forceFetch &&
        _jwkCache.containsKey(cacheKey)) {
      return _jwkCache[cacheKey]!;
    }

    final jwksClient = await RestClient.connect(jwksUri);
    try {
      final jwksRequest = await jwksClient.get('').thenGetJsonBody();

      if (jwksRequest['keys'] is! List) {
        throw Exception('Invalid JWKS.');
      }

      for (final key in jwksRequest['keys']) {
        if (key['alg'] == alg && key['kid'] == kid) {
          if (key['n'] is String && key['e'] is String) {
            final n = _decodeBigInt(base64Decode(addBase64Padding(key['n'])));
            final e = _decodeBigInt(base64Decode(addBase64Padding(key['e'])));
            final pub = RSAPublicKey(n, e);
            if (read(service.enable)) {
              return _jwkCache[cacheKey] = pub;
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

  @override
  void clearCache() {
    _jwkCache.clear();
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
