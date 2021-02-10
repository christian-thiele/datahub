import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

class Api extends ApiBase {
  Api(List<ApiResource<TransferObject>> resources) : super(resources);
}

void main() {
  group('ApiBase', () {
    late final ApiBase api;

    setUp(() {
      api = Api([]);
    });

    test('serve and cancel', () async {
      final token = CancellationToken();
      final task = api.serve(InternetAddress.loopbackIPv4.address, 8082,
          cancellationToken: token);
      await Future.delayed(Duration(seconds: 3));
      token.cancel();
      await task;
    }, timeout: Timeout(Duration(seconds: 7)));
  });
}
