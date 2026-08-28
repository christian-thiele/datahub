import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

/// An ApiNode that reads configuration during route construction, like
/// real-world nodes do (e.g. a configurable base path).
class ConfiguredApi extends ApiNode {
  const ConfiguredApi();

  @override
  List<ApiRoute> buildRoutes() {
    final base = const Config<String>('basePath').read();
    return [
      ResourceEndpoint(
        matcher: RoutePattern('$base/items'),
        get: (request) => null,
      ),
    ];
  }
}

void main() {
  test('describe builds the document without initializing services', () {
    final host = ApplicationHost(
      components: [
        ApiService(port: Config.value(0), routes: const [ConfiguredApi()]),
      ],
      arguments: const [],
      initialConfig: const {},
    );
    host.configuration.addConfigMap({'basePath': '/v1'});

    final mode = DescribeMode(
      target: DescribeMode.targetOpenApi,
      title: 'Configured API',
      version: '2.0.0',
    );
    final document = mode.describe(host);

    expect(
      document['info'],
      equals({'title': 'Configured API', 'version': '2.0.0'}),
    );
    expect((document['paths'] as Map).keys, contains('/v1/items'));
    expect(host.state, equals(ServiceHostState.uninitialized));
  });

  test('missing config surfaces as error', () {
    final host = ApplicationHost(
      components: [
        ApiService(port: Config.value(0), routes: const [ConfiguredApi()]),
      ],
      arguments: const [],
      initialConfig: const {},
    );

    final mode = DescribeMode(target: DescribeMode.targetOpenApi);
    expect(() => mode.describe(host), throwsA(anything));
  });

  test('unknown target throws', () {
    final host = ApplicationHost(
      components: const [],
      arguments: const [],
      initialConfig: const {},
    );

    final mode = DescribeMode(target: 'graphql');
    expect(() => mode.describe(host), throwsA(isA<ApiError>()));
  });

  test('fromEnvironment reads variables', () {
    final mode = DescribeMode.fromEnvironment({
      'DATAHUB_DESCRIBE': 'openapi',
      'DATAHUB_DESCRIBE_OUT': '/tmp/spec.json',
      'DATAHUB_DESCRIBE_TITLE': 'My API',
      'DATAHUB_DESCRIBE_VERSION': '3.0.0',
    });
    expect(mode, isNotNull);
    expect(mode!.target, equals('openapi'));
    expect(mode.outPath, equals('/tmp/spec.json'));
    expect(mode.title, equals('My API'));
    expect(mode.version, equals('3.0.0'));

    expect(DescribeMode.fromEnvironment({}), isNull);
  });
}
