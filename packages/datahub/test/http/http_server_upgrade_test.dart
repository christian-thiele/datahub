import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:datahub/http.dart';
import 'package:test/test.dart';

void main() {
  group('HTTP Upgrade', () {
    late HttpServer httpServer;
    setUp(() async {
      httpServer = HttpServer(
        await io.ServerSocket.bind(io.InternetAddress.loopbackIPv4, 1234),
        (request) async {
          return UpgradeHttpResponse(request.requestUri, {}, (socket) {
            socket.listen((data) {
              socket.add(data);
              socket.close();
            });
          });
        },
        (dynamic error, StackTrace stack) => fail(error.toString()),
        (dynamic error, StackTrace stack) => fail(error.toString()),
        (dynamic error, StackTrace stack) => fail(error.toString()),
      );
    });

    tearDown(() => httpServer.close());

    test('HTTP 1.1 Send text data', () async {
      final client = io.HttpClient();
      final request = await client.get('127.0.0.1', 1234, '/connection');
      request.headers.add('Connection', 'Upgrade');
      final response = await request.close();
      expect(response.statusCode, 101);
      expect(response.headers['Connection'], ['Upgrade']);

      final socket = await response.detachSocket();
      final completer = Completer<List<int>>();
      socket.listen(
        (data) => completer.complete(data),
        onError: (e) => fail(e.toString()),
      );
      socket.write('test');
      expect(await completer.future.then((d) async => utf8.decode(d)), 'test');
    });
  }, tags: ['api']);
}
