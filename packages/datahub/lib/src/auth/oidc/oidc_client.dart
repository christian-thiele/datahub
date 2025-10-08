import 'package:datahub/datahub.dart';

class OidcClient {
  final Uri issuer;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final String? audience;
  final String? clientId;
  final String? clientSecret;
  final List<String>? scopes;

  OidcClient({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.audience,
    this.scopes,
    this.clientId,
    this.clientSecret,
  });

  static Future<OidcClient> discover(
    Uri issuer, {
    String? audience,
    String? clientId,
    String? clientSecret,
  }) async {
    final client = await RestClient.connect(
      Uri(scheme: issuer.scheme, host: issuer.host, port: issuer.port),
    );
    try {
      final config = await client
          .get('${issuer.path}/.well-known/openid-configuration')
          .thenGetData($OidcConfiguration.bean);

      return OidcClient(
        issuer: issuer,
        authorizationEndpoint: Uri.parse(config.authorizationEndpoint),
        tokenEndpoint: Uri.parse(config.tokenEndpoint),
        audience: audience,
        clientId: clientId,
        clientSecret: clientSecret,
      );
    } finally {
      await client.close();
    }
  }

  Uri createAuthUri(
    String redirectUrl,
    String state,
    String challenge, {
    List<String>? scope,
  }) {
    return authorizationEndpoint.replace(
      queryParameters: {
        'redirect_uri': redirectUrl,
        'client_id': clientId.toString(),
        'response_type': 'code',
        if (scope case final scope?) 'scope': scope,
        'state': state,
        'code_challenge_method': 'S256',
        'code_challenge': challenge,
        if (audience case final audience?) 'audience': audience,
        if (scopes case final scopes? when scopes.isNotEmpty)
          'scope': scopes.join('+'),
      },
    );
  }

  Future<OidcResponse> getToken(
    String code,
    String verifier,
    String redirectUrl,
  ) async {
    final client = await RestClient.connect(
      Uri(
        scheme: tokenEndpoint.scheme,
        host: tokenEndpoint.host,
        port: tokenEndpoint.port,
      ),
    );
    try {
      return await client
          .post(
            tokenEndpoint.path,
            HttpFormData({
              'grant_type': 'authorization_code',
              if (clientId case final clientId?) 'client_id': clientId,
              if (clientSecret case final clientSecret?)
                'client_secret': clientSecret,
              'code': code,
              'code_verifier': verifier,
              'redirect_uri': redirectUrl,
              if (audience case final audience?) 'audience': audience,
              if (scopes case final scopes? when scopes.isNotEmpty)
                'scope': scopes.join('+'),
            }),
          )
          .thenGetData($OidcResponse.bean);
    } finally {
      await client.close();
    }
  }

  Future<OidcResponse> refreshToken(String refreshToken) async {
    final client = await RestClient.connect(
      Uri(
        scheme: tokenEndpoint.scheme,
        host: tokenEndpoint.host,
        port: tokenEndpoint.port,
      ),
    );
    try {
      return await client
          .post(
            tokenEndpoint.path,
            HttpFormData({
              'grant_type': 'refresh_token',
              'refresh_token': refreshToken,
              if (clientId case final clientId?) 'client_id': clientId,
              if (clientSecret case final clientSecret?)
                'client_secret': clientSecret,
            }),
          )
          .thenGetData($OidcResponse.bean);
    } finally {
      await client.close();
    }
  }
}
