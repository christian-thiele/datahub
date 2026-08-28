import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

import '_fixture/pet.dart';

void main() {
  final routes = <ApiNode>[
    ResourceEndpoint(
      matcher: RoutePattern('/pets'),
      get: (request) => ApiResponse.dynamic([]),
      operations: {
        HttpRequestMethod.get: ApiOperation(
          summary: 'List all pets.',
          responses: {200: ApiContent.bean($Pet.bean, isList: true)},
        ),
      },
    ),
  ];

  declareTest(
    'OpenAPI endpoint',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ...routes,
          OpenApiEndpoint(
            describes: routes,
            title: 'Pet API',
            version: '1.0.0',
          ),
        ],
      ),
    ],
    () async {
      final client = Find<Api>().find().connectHttp11();

      final document = await client.get('/openapi.json').thenGetJsonBody();

      expect(document['openapi'], equals('3.0.3'));
      expect(
        document['info'],
        equals({'title': 'Pet API', 'version': '1.0.0'}),
      );

      final paths = document['paths'] as Map<String, dynamic>;
      expect(paths.keys, equals(['/pets']));
      expect((paths['/pets'] as Map).keys, equals(['get']));

      final schemas =
          (document['components'] as Map)['schemas'] as Map<String, dynamic>;
      expect(schemas.keys, containsAll(['Pet', 'Owner', 'ErrorResponse']));
    },
  );
}
