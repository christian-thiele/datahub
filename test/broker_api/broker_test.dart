import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

import '../dto/test_dto.dart';
import '../utils/test_config.dart';
import 'example_api.dart';

void main() {
  test('Test ExampleApi', _testExampleApi,
      timeout: Timeout(Duration(minutes: 5)));
}

Future<void> _testExampleApi() async {
  final token = CancellationToken();
  final serviceHost = ServiceHost([
    () => TestConfigService(),
    () => AmqpBrokerService(),
    () => ExampleApiImplService(),
    () => ExampleApiClient(),
  ], catchSignal: false, onInitialized: () async {
    final client = resolve<ExampleApiClient>();
    client.doSomething(5);
    final result = await client.getSomeString(TestDto(
        category: EventCategory.party,
        privacyLevel: 3,
        shortDescription: 'abc def 123'));
    expect(result.someStr, equals('ABC DEF 123'));
    expect(result.someInt, equals(3));
    final result2 = await client.getSomeString(TestDto(
        category: EventCategory.party,
        privacyLevel: 8,
        shortDescription: 'test some'));
    expect(result2.someStr, equals('TEST SOME'));
    expect(result2.someInt, equals(8));

    token.cancel();
  });
  await serviceHost.run(token);
}