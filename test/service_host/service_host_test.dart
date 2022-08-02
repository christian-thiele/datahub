import 'package:boost/boost.dart' as boost;
import 'package:datahub/datahub.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Service Host', () {
    test('Default config', _defaultConfig);
    test('YAML config', _yamlConfig);
  });
}

Future _defaultConfig() async {
  final token = boost.CancellationToken();
  final serviceHost = ServiceHost([],
      catchSignal: false,
      config: {
        'myValue': 1234,
        'sub': {
          'myValue': 4321,
        }
      }, onInitialized: () {
    final configService = resolve<ConfigService>();
    expect(configService.fetch(ConfigPath('myValue')), equals(1234));
    expect(configService.fetch(ConfigPath('sub.myValue')), equals(4321));
  });
  final task = serviceHost.run(token);
  await Future.delayed(Duration(seconds: 3));
  token.cancel();
  await task;
}

Future _yamlConfig() async {
  final token = boost.CancellationToken();
  final serviceHost = ServiceHost([],
      catchSignal: false,
      config: {
        'fileValue': 'will be overwritten',
      },
      args: ['test/service_host/test_config.yml'], onInitialized: () {
    final configService = resolve<ConfigService>();
    expect(configService.fetch(ConfigPath('fileValue')), equals('abc 123'));

    final fileList = configService.fetch<List<String>>(ConfigPath('fileList'));
    expect(fileList, isA<List<String>>());
    expect(fileList, orderedEquals(['valueA', 'valueB', 'valueC']));

    final absentValue = configService.fetch<int?>(ConfigPath('doesntexist'));
    expect(absentValue, isNull);

    final complexList = configService.fetch(ConfigPath('complexList'));
    expect(complexList, isA<List>());
    expect(complexList[0], equals('simple'));
    expect(complexList[1], equals(1234));
    expect(complexList[2]['complex'], isA<Map<String, dynamic>>());
    expect(complexList[2]['complex']['subVal'], equals('xxx'));
  });
  final task = serviceHost.run(token);
  await Future.delayed(Duration(seconds: 3));
  token.cancel();
  await task;
}
