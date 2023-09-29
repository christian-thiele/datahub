import 'dart:io';

import 'package:datahub/datahub.dart';

void main(List<String> args) async {
  final host = ApplicationHost(
    [
      () => TestService('test'),
    ],
    onInitialized: onInit,
  );
  await host.run();

  // required because of signal catching inside ServiceHost
  exit(0);
}

class TestService extends BaseService {
  // use ioc to inject other services
  final log = resolve<LogService>();

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
  }
}

void onInit() {
  resolve<LogService>().info('Initialization done!');
}
