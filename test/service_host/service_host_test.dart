import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';

import 'package:test/test.dart';

void main() {
  group('Service Host', () {
    test(
      'Default config',
      TestHost(
        [],
        config: {
          'myValue': 1234,
          'sub': {
            'myValue': 4321,
          }
        },
      ).test(() async {
        final configService = resolve<ConfigService>();
        expect(configService.fetch(ConfigPath('myValue')), equals(1234));
        expect(configService.fetch(ConfigPath('sub.myValue')), equals(4321));
      }),
    );

    test(
      'YAML config',
      TestHost(
        [],
        config: {'fileValue': 'will be overwritten'},
        args: ['test/service_host/test_config.yml'],
      ).test(() async {
        final configService = resolve<ConfigService>();
        expect(configService.fetch(ConfigPath('fileValue')), equals('abc 123'));

        final fileList =
            configService.fetch<List<String>>(ConfigPath('fileList'));
        expect(fileList, isA<List<String>>());
        expect(fileList, orderedEquals(['valueA', 'valueB', 'valueC']));

        final absentValue =
            configService.fetch<int?>(ConfigPath('doesntexist'));
        expect(absentValue, isNull);

        final complexList = configService.fetch(ConfigPath('complexList'));
        expect(complexList, isA<List>());
        expect(complexList[0], equals('simple'));
        expect(complexList[1], equals(1234));
        expect(complexList[2]['complex'], isA<Map<String, dynamic>>());
        expect(complexList[2]['complex']['subVal'], equals('xxx'));
      }),
    );

    test(
      'Shutdown on Critical Error',
      TestHost(
        [
          ShutdownNotifyService.new,
        ],
        config: {
          'datahub': {'shutdownOnCriticalError': true}
        },
      ).test(() async {
        resolve<LogService>().critical('This is a fatal error.');
        await resolve<ShutdownNotifyService>().completer.future;
      }),
      timeout: Timeout(
        const Duration(seconds: 3),
      ),
    );
  });
}

class ShutdownNotifyService extends BaseService {
  final completer = Completer();

  @override
  Future<void> shutdown() async {
    completer.complete();
  }
}
