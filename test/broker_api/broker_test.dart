import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/test.dart';

import '../dto/test_dto.dart';
import 'example_api.dart';

void main() {
  final host = TestHost(
    [
      () => AmqpBrokerService('testBrokerConfig'),
      () => ExampleApiImplService(),
      () => ExampleApiClient(),
    ],
    config: {
      'testBrokerConfig': {
        'host': 'localhost',
        'user': 'guest',
        'password': 'guest'
      }
    },
  );

  test(
    'Test ExampleApi',
    host.test(() async {
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

      final result3 = await client.getEnumName(TestDto(
          category: EventCategory.hangout,
          privacyLevel: 0,
          shortDescription: ''));

      expect(result3, equals('EventCategory.hangout'));

      final result4 = await client.getSomeMoreSync(
        TestDto(
            privacyLevel: 1,
            category: EventCategory.party,
            shortDescription: 'first '),
        TestDto(
            privacyLevel: 1,
            category: EventCategory.party,
            shortDescription: 'second '),
        'last',
      );

      expect(result4.someStr, equals('first second last'));

      try {
        await client.getSomeNotWorking(0);
      } catch (e) {
        expect(e, isA<ApiRequestException>());
        expect((e as ApiRequestException).message,
            contains('This did not work at all.'));
        expect(e.statusCode, equals(500));
      }

      try {
        await client.getSomeNotWorking(1);
      } catch (e) {
        expect(e, isA<ApiRequestException>());
        expect(
            (e as ApiRequestException).message, contains('This did not work.'));
        expect(e.statusCode, equals(20));
      }
    }),
    timeout: Timeout(Duration(minutes: 5)),
    skip: true,
  );
}
