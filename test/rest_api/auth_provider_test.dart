import 'dart:io';

import 'package:datahub/api.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/bearer_token_test_provider.dart';
import 'lib/echo_api.dart';
import 'lib/validate_session_endpoint.dart';

void main() {
  TestHost(
    [
      () => ApiService(
            'api',
            [
              EchoEndpoint(),
              ValidateSessionEndpoint<BearerAuthSession>(
                RoutePattern('/session'),
                validate: (s) => s.token.token == 'secretpassword',
              ),
            ],
            middleware: (i) => BearerTokenTestProvider(
              i,
              token: 'secretpassword',
            ),
          ),
    ],
    config: {
      'api': {
        'port': 1234,
      },
    },
  ).declare((host) {
    host.apiTest('Should reject unauthorized requests with 401',
        (client) async {
      final response = await client.get('/echo', throwOnError: false);
      expect(response, hasStatusCode(equals(401)));
      await response.discard();
    });

    host.apiTest('Should reject invalid token requests with 401',
        (client) async {
      final response = await client.get(
        '/echo',
        headers: {
          HttpHeaders.authorizationHeader: ['Bearer wrongpassword'],
        },
        throwOnError: false,
      );
      expect(response, hasStatusCode(equals(401)));
      await response.discard();
    });

    host.apiTest('Should allow valid token requests', (client) async {
      final response = await client.get(
        '/echo',
        headers: {
          HttpHeaders.authorizationHeader: ['Bearer secretpassword'],
        },
      );
      await response.discard();
    });

    host.apiTest('Should pass session to ApiEndpoint', (client) async {
      final response = await client.get(
        '/session',
        headers: {
          HttpHeaders.authorizationHeader: ['Bearer secretpassword'],
        },
      );
      await response.discard();
    });
  });

  TestHost(
    [
      () => ApiService(
            'api',
            [
              EchoEndpoint(),
              ValidateSessionEndpoint<BearerAuthSession>(
                RoutePattern('/session'),
                validate: (s) => s.token.token == 'secretpassword',
              ),
            ],
            middleware: (i) => BearerTokenTestProvider(
              i,
              token: 'secretpassword',
              requireAuthorization: false,
            ),
          ),
    ],
    config: {
      'api': {
        'port': 1235,
      },
    },
  ).declare((host) {
    host.apiTest(
        'Should allow unauthorized requests, when requireAuthorization: false',
        (client) async {
      final response = await client.get('/echo');
      await response.discard();
    });
  });
}
