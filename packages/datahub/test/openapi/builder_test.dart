import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

import '_fixture/pet.dart';

List<ApiNode> _routes() => [
  JwtAuthMiddleware(
    routes: [
      ResourceEndpoint(
        matcher: RoutePattern('/pets/{id?}'),
        get: (request) => null,
        post: (request) => null,
        operations: {
          HttpRequestMethod.get: ApiOperation(
            summary: 'List or get pets.',
            tags: const ['pets'],
            queryParams: const [
              ApiQueryParam(
                'limit',
                type: TypeCheck<int?>(),
                description: 'Maximum number of results.',
              ),
            ],
            responses: {200: ApiContent.bean($Pet.bean, isList: true)},
          ),
          HttpRequestMethod.post: ApiOperation(
            summary: 'Create a pet.',
            requestBody: ApiContent.bean($Pet.bean),
            responses: {201: ApiContent.bean($Pet.bean)},
          ),
        },
      ),
    ],
  ),
  ApiEndpointDelegate(
    matcher: RoutePattern('/health'),
    method: HttpRequestMethod.get,
    delegate: (request) => null,
  ),
];

void main() {
  test('builds OpenAPI document from route tree', () {
    final builder = OpenApiBuilder(
      title: 'Test API',
      version: '1.2.3',
      serverUrls: const ['https://api.example.com'],
    );
    final document = builder.build(_routes());

    expect(document['openapi'], equals('3.0.3'));
    expect(document['info'], equals({'title': 'Test API', 'version': '1.2.3'}));
    expect(
      document['servers'],
      equals([
        {'url': 'https://api.example.com'},
      ]),
    );

    final paths = document['paths'] as Map<String, dynamic>;
    expect(paths.keys, containsAll(['/pets', '/pets/{id}', '/health']));

    final getPet = (paths['/pets/{id}'] as Map)['get'] as Map<String, dynamic>;
    expect(getPet['summary'], equals('List or get pets.'));
    expect(getPet['tags'], equals(['pets']));
    expect(
      getPet['security'],
      equals([
        {'bearerAuth': <String>[]},
      ]),
    );
    expect(
      getPet['parameters'],
      equals([
        {
          'name': 'id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string'},
        },
        {
          'name': 'limit',
          'in': 'query',
          'description': 'Maximum number of results.',
          'schema': {'type': 'integer'},
        },
      ]),
    );

    final responses = getPet['responses'] as Map<String, dynamic>;
    expect(
      (responses['200'] as Map)['content'],
      equals({
        'application/json': {
          'schema': {
            'type': 'array',
            'items': {r'$ref': '#/components/schemas/Pet'},
          },
        },
      }),
    );
    expect(responses.keys, containsAll(['400', '404', '500', '401', '403']));

    final postPet = (paths['/pets'] as Map)['post'] as Map<String, dynamic>;
    expect(
      postPet['requestBody'],
      equals({
        'required': true,
        'content': {
          'application/json': {
            'schema': {r'$ref': '#/components/schemas/Pet'},
          },
        },
      }),
    );

    final health = paths['/health'] as Map<String, dynamic>;
    expect(health.keys, equals(['get']));
    final getHealth = health['get'] as Map<String, dynamic>;
    expect(getHealth.containsKey('security'), isFalse);
    expect((getHealth['responses'] as Map).containsKey('401'), isFalse);

    final components = document['components'] as Map<String, dynamic>;
    expect(
      (components['schemas'] as Map).keys,
      containsAll(['Pet', 'Owner', 'ErrorResponse']),
    );
    expect(
      components['securitySchemes'],
      equals({
        'bearerAuth': {
          'type': 'http',
          'scheme': 'bearer',
          'bearerFormat': 'JWT',
        },
      }),
    );
  });

  test('excludes hidden endpoints', () {
    final builder = OpenApiBuilder(title: 'Test API', version: '1.0.0');
    final document = builder.build([
      ..._routes(),
      OpenApiEndpoint(describes: const []),
    ]);

    final paths = document['paths'] as Map<String, dynamic>;
    expect(paths.containsKey('/openapi.json'), isFalse);
  });

  test('warns about undeclared methods', () {
    final builder = OpenApiBuilder(title: 'Test API', version: '1.0.0');
    final document = builder.build([
      ApiEndpointDelegate(
        matcher: RoutePattern('/legacy'),
        delegate: (request) => null,
      ),
    ]);

    final paths = document['paths'] as Map<String, dynamic>;
    expect((paths['/legacy'] as Map).keys, equals(['get']));
    expect(builder.warnings, hasLength(1));
  });
}
