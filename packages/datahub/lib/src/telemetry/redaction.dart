/// Redaction of credentials in logs and span attributes.
abstract final class Redaction {
  static const redacted = 'REDACTED';

  /// Lowercase names of headers whose values are always redacted.
  static const sensitiveHeaders = {
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
  };

  /// Lowercase names of query parameters whose values are redacted.
  static const sensitiveQueryParams = {
    'access_token',
    'id_token',
    'refresh_token',
    'token',
    'api_key',
    'apikey',
    'password',
    'secret',
    'client_secret',
    // redacted by default according to the semantic conventions
    'awsaccesskeyid',
    'signature',
    'sig',
    'x-goog-signature',
  };

  /// [query] with the values of [sensitiveQueryParams] replaced.
  static String redactQuery(String query) => query
      .split('&')
      .map((param) {
        final name = param.split('=').first;
        final String decoded;
        try {
          decoded = Uri.decodeQueryComponent(name).toLowerCase();
        } on ArgumentError {
          return param;
        }
        return sensitiveQueryParams.contains(decoded)
            ? '$name=$redacted'
            : param;
      })
      .join('&');

  /// Replaces a header value, but keeps the authentication scheme (e.g.
  /// `Bearer`) for debugging.
  static String redactHeaderValue(String value) {
    final scheme = RegExp(r'^[A-Za-z][A-Za-z0-9-]* ').stringMatch(value);
    return '${scheme ?? ''}$redacted';
  }

  /// [uri] for `url.full`: user info is replaced and the values of
  /// [sensitiveQueryParams] are redacted, the fragment is removed.
  static String redactUrl(Uri uri) {
    final base = Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo.isEmpty ? null : '$redacted:$redacted',
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();
    return uri.hasQuery ? '$base?${redactQuery(uri.query)}' : base;
  }
}
