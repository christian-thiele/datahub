import 'dart:io';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

class Api extends ApiBase {
  Api(List<ApiEndpoint> resources) : super(resources);
}

class StaticEndpoint extends ApiEndpoint {
  StaticEndpoint(String path) : super(path);

  @override
  Future delete(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams) async {
    print('deleted');
  }

  @override
  Future get(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams) async {
    return {'prop1': 'val1', 'prop2': 2, 'prop3': true};
  }

  @override
  Future patch(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams, Uint8List bodyBytes) async {
    // TODO: implement patch
    throw UnimplementedError();
  }

  @override
  Future post(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams, Uint8List bodyBytes) async {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future put(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams, Uint8List bodyBytes) async {
    // TODO: implement put
    throw UnimplementedError();
  }

}

class StaticEndpoint2 extends ApiEndpoint {
  StaticEndpoint2(String path) : super(path);

  @override
  Future delete(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams) async {
    print('deleted');
  }

  @override
  Future get(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams) async {
    return {'lel': urlParams['moin'], 'prop2': 2, 'prop3': true};
  }

  @override
  Future patch(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams, Uint8List bodyBytes) async {
    // TODO: implement patch
    throw UnimplementedError();
  }

  @override
  Future post(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams, Uint8List bodyBytes) async {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future put(Map<String, dynamic> urlParams, Map<String, dynamic> queryParams, Uint8List bodyBytes) async {
    // TODO: implement put
    throw UnimplementedError();
  }

}

void main() {
  group('ApiBase', () {
    late final ApiBase api;

    setUp(() {
      api = Api([
        StaticEndpoint('/test'),
        StaticEndpoint2('/test2/{moin}')
      ]);
    });

    test('serve and cancel', () async {
      final token = CancellationToken();
      final task = api.serve(InternetAddress.loopbackIPv4.address, 8082,
          cancellationToken: token);
      await Future.delayed(Duration(seconds: 3));
      //token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}
