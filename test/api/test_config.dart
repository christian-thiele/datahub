import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

part 'test_config.g.dart';

@GenerateConfig()
class TestConfig implements ApiConfig {
  @override
  final address = InternetAddress.anyIPv4;

  @override
  @ConfigOption(defaultValue: 1234)
  final int port;

  TestConfig(this.port);
}
