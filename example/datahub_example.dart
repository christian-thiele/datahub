import 'dart:io';
import 'dart:math';

import 'package:datahub/datahub.dart';

class TestEndpoint extends ApiEndpoint {
  final _inst = resolve<InstrumentationService>();

  TestEndpoint() : super(RoutePattern('/'));

  @override
  Future<dynamic> get(ApiRequest request) async {
    await _inst.trace('Waiting', {'some': 'stuff'}, () async {
      await Future.delayed(const Duration(milliseconds: 250));
    });

    await _inst.trace('Waiting some more', {'some': 'stuff'}, () async {
      await Future.delayed(const Duration(milliseconds: 150));

      if (request.getParam<bool?>('fail') == true) {
        throw ApiRequestException.badRequest('Failure requested!');
      }
    });
    return TextResponse.plain('works!');
  }
}

void main(List<String> args) async {
  final host = ApplicationHost(
      [
        () => TestService('test'),
        () => ApiService('api', [TestEndpoint()]),
      ],
      onInitialized: onInit,
      config: {
        'api': {'port': 1234, 'metricPrefix': 'test_api'}
      });
  await host.run();

  // required because of signal catching inside ServiceHost
  exit(0);
}

class TestService extends BaseService {
  // use ioc to inject other services
  final log = resolve<LogService>();
  final funMetric = resolve<InstrumentationService>().counter(
    'fun_total',
    help: 'Shows how much fun it is to use datahub.',
  );

  TestService(String configPath) : super(configPath);

  @override
  Future<void> initialize() async {
    // some logs
    log.debug('Some debug message.');
    log.verbose('Some verbose message.');
    log.info('Some info message.');
    log.warn('Some warn message.');
    log.error('Some error message.');
    log.critical('Some critical message.');

    final _client =
        await RestClient.connect(Uri.parse('http://localhost:1234'));

    resolve<SchedulerService>().schedule(() async {
      funMetric.inc();
      final fail = Random().nextBool();
      final response = await _client.get('/', query: {
        'fail': ['$fail']
      });
      response.discard();
    }, Schedule.repeat(const Duration(seconds: 3)));
  }
}

void onInit() {
  resolve<LogService>().info('Initialization done!');
}
