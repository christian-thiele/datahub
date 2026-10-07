import 'dart:async';

import 'package:datahub/config.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/utils.dart';
import 'package:pointycastle/pointycastle.dart';

import 'abstract/key_cache.dart';

class KeyService implements Service {
  final Config<bool> enable;

  const KeyService({
    this.enable = const Config('enableKeyCache', defaultValue: true),
  });

  @override
  ServiceInstance<KeyService> createInstance() => _KeyServiceInstance();
}

class _KeyServiceInstance extends ServiceInstance<KeyService>
    implements KeyCache {
  final _jwkCache = <_CacheKey, RSAPublicKey>{};
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
      if (read(service.enable)) {
        _openIdCache[issuer] = jwksUri;
      }
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
    final cacheKey = _CacheKey(jwksUri, alg, kid);
    if (read(service.enable) &&
        !forceFetch &&
        _jwkCache.containsKey(cacheKey)) {
      return _jwkCache[cacheKey]!;
    }

    final jwksClient = await RestClient.connect(jwksUri);
    try {
      final jwksRequest = await jwksClient.get('').thenGetJsonBody();

      if (jwksRequest['keys'] is! List) {
        throw ApiException('Invalid JWKS.');
      }

      for (final key in jwksRequest['keys']) {
        if (key['alg'] == alg && key['kid'] == kid) {
          if (key['n'] is String && key['e'] is String) {
            final n = base64UintDecode(key['n']);
            final e = base64UintDecode(key['e']);
            final pub = RSAPublicKey(n, e);
            if (read(service.enable)) {
              return _jwkCache[cacheKey] = pub;
            } else {
              return pub;
            }
          } else {
            throw ApiException('Could not find e/n properties on key.');
          }
        }
      }
    } finally {
      await jwksClient.close();
    }

    throw ApiRequestException.unauthorized('Key not found in JWKS.');
  }

  @override
  void clearCache() {
    _jwkCache.clear();
    _openIdCache.clear();
  }
}

class _CacheKey {
  final Uri jwks;
  final String alg;
  final String kid;

  const _CacheKey(this.jwks, this.alg, this.kid);

  @override
  bool operator ==(Object other) {
    if (other is _CacheKey) {
      return jwks == other.jwks && alg == other.alg && kid == other.kid;
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([jwks, alg, kid]);

  @override
  String toString() => '$jwks : $kid ($alg)';
}
