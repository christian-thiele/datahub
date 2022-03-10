import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

part 'test_config.g.dart';

@GenerateConfig()
class TestConfig implements ApiConfig, BrokerConfig {
  @override
  final address = InternetAddress.anyIPv4;

  @override
  @ConfigOption(defaultValue: 1234)
  final int port;

  TestConfig(
    this.port,
    this.brokerHost,
    this.brokerPort,
    this.brokerUser,
    this.brokerPassword,
  );

  @override
  @ConfigOption(defaultValue: 'localhost')
  final String brokerHost;

  @override
  @ConfigOption(defaultValue: 'guest')
  final String brokerUser;

  @override
  @ConfigOption(defaultValue: 'guest')
  final String brokerPassword;

  @override
  @ConfigOption(defaultValue: 5672)
  final int brokerPort;
}
