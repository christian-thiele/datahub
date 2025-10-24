import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:pointycastle/export.dart';

void main() {
  final idp = 'http://localhost:8081/realms/local-oidc';
  final returnPort = 56542;
  final clientId = 'datahub-test';
  final secretCode = 'my_cool_random_challenge123-with-more-letterssss';
  final codeChallenge = base64UrlEncode(
    SHA256Digest().process(utf8.encode(secretCode)),
  ).replaceAll('=', '');

  final redirectUrl = 'http://localhost:$returnPort/return-auth';

  late final authUrl =
      '$idp/protocol/openid-connect/auth?redirect_uri=${Uri.encodeQueryComponent(redirectUrl)}&client_id=${Uri.encodeQueryComponent(clientId)}&response_type=code&state=teststate&scope=openid&code_challenge_method=S256&code_challenge=$codeChallenge';

  late final loginPageHtml =
      '<html lang="en"><head><title>Login</title></head><body><h1>Login</h1><br/><a href="$authUrl">Click here</a></body></html>';

  String authorizedHtml(String subject) =>
      '<html lang="en"><head><title>Success!</title></head><body><h1>Successfully Authorized</h1><br/><p>Hello $subject! You can close this page now.</p></body></html>';

  declareTest(
    'OIDC Flow',
    compose: 'test/auth/docker-compose.yml',
    [
      ApiService(
        port: Config.value(returnPort),
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/return-auth'),
            get: (request) async {
              final configClient = await RestClient.connect(Uri.parse(idp));
              final config = await configClient
                  .get('/.well-known/openid-configuration')
                  .thenGetData($OidcConfiguration.bean);
              await configClient.close();

              final authCode = request.getParam<String>('code');
              final tokenClient = await RestClient.connect(
                Uri.parse(config.tokenEndpoint),
              );
              final tokenResponse = await tokenClient
                  .post(
                    '/',
                    HttpFormData({
                      'grant_type': 'authorization_code',
                      'client_id': clientId,
                      'code': authCode,
                      'redirect_uri': redirectUrl,
                      'code_verifier': secretCode,
                    }),
                  )
                  .thenGetJsonBody();
              await tokenClient.close();

              final token = Jwt(tokenResponse['access_token']);

              return TextResponse.html(
                authorizedHtml(
                  token.payload['preferred_username'] ??
                      token.payload['email'] ??
                      token.sub ??
                      '-',
                ),
              );
            },
          ),
          OidcAuthMiddleware(
            identityProvider: Config.value(idp),
            audience: Config.value('datahub-test'),
            clientId: Config.value('datahub-test'),
            requireSession: false,
            routes: [
              ResourceEndpoint(
                get: (request) async {
                  final session = Context.zoneSession<OidcSession?>();
                  if (session case OidcSession(
                    authenticationToken: Jwt(sub: final String subject),
                  )) {
                    return TextResponse.html(authorizedHtml(subject));
                  } else {
                    return TextResponse.html(loginPageHtml);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ],
    () async {
      // TODO implement client test logic
      await Future.delayed(const Duration(hours: 1));
    },
  );
}
