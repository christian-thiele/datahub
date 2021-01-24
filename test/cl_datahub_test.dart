import 'dart:io';

import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

class Api extends ApiBase {
  Api(List<ApiResource<TransferObject>> resources) : super(resources);
}

void main() {
  group('A group of tests', () {
    late final ApiBase api;

    setUp(() {
      api = Api([]);
    });

    test('First Test', () async {
      await api.serve(InternetAddress.loopbackIPv4.address, 8082);
    });
  });
}
