import 'dart:async';
import 'dart:io';

import 'package:datahub/api.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/rest_client.dart';

import 'test_case.dart';

class ApiTest<T extends ApiService> extends TestCase {
  FutureOr<void> Function(RestClient client) delegate;

  ApiTest(
    super.description,
    this.delegate, {
    super.skip,
    super.timeout,
  });

  @override
  Future<void> execute() async {
    final api = resolve<T>();
    final client = await RestClient.connect(
      Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.host,
        port: api.port,
        path: api.basePath,
      ),
    );
    await delegate(client);
  }
}
