import 'package:pointycastle/export.dart';

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
