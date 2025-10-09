import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

import 'lib/auth_service.dart';

void main() {
  declareTest(
    'BasicAuth Simple',
    [
      AuthService(),
      ApiService(
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/public'),
            get: (request) => EmptyResponse(),
          ),
          BasicAuthMiddleware(
            routes: [
              ResourceEndpoint(
                matcher: RoutePattern('/private'),
                get: (request) => ApiResponse.dynamic({
                  'user': Context.zoneSession<TestSession>().user,
                }),
              ),
            ],
          ),
        ],
      ),
    ],
    () async {
      final client = await RestClient.connect(
        Uri.parse('http://localhost:8080/'),
      );
      client.auth = null;
      expect(await client.get('/public'), isSuccess);
      expect(
        await client.get('/private', throwOnError: false),
        hasStatusCode(equals(401)),
      );

      client.auth = BasicAuth('user1', 'wrong');
      expect(await client.get('/public'), isSuccess);
      expect(
        await client.get('/private', throwOnError: false),
        hasStatusCode(equals(401)),
      );

      client.auth = BasicAuth('user1', '1resu');
      expect(
        await client.get('/private', throwOnError: false).thenGetJsonBody(),
        equals({'user': 'user1'}),
      );
    },
  );

  declareTest(
    'BasicAuth requireSession: false',
    [
      AuthService(),
      ApiService(
        routes: [
          BasicAuthMiddleware(
            requireSession: false,
            routes: [
              ResourceEndpoint(
                matcher: RoutePattern('/public'),
                get: (request) => ApiResponse.dynamic({
                  'user': Context.zoneSession<TestSession?>()?.user ?? false,
                }),
              ),
              ResourceEndpoint(
                matcher: RoutePattern('/private'),
                get: (request) => ApiResponse.dynamic({
                  'user': Context.zoneSession<TestSession>().user,
                }),
              ),
            ],
          ),
        ],
      ),
    ],
    () async {
      final client = await RestClient.connect(
        Uri.parse('http://localhost:8080/'),
      );
      client.auth = null;
      expect(
        await client.get('/public').thenGetJsonBody(),
        equals({'user': false}),
      );
      expect(
        await client.get('/private', throwOnError: false),
        hasStatusCode(equals(401)),
      );

      client.auth = BasicAuth('user1', 'wrong');
      expect(
        await client.get('/public', throwOnError: false),
        hasStatusCode(equals(401)),
      );
      expect(
        await client.get('/private', throwOnError: false),
        hasStatusCode(equals(401)),
      );

      client.auth = BasicAuth('user1', '1resu');
      expect(
        await client.get('/public', throwOnError: false).thenGetJsonBody(),
        equals({'user': 'user1'}),
      );
      expect(
        await client.get('/private', throwOnError: false).thenGetJsonBody(),
        equals({'user': 'user1'}),
      );
    },
  );
}
