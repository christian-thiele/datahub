import 'dart:async';
import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';
import 'package:web_socket/web_socket.dart';

final testScenario = [
  ApiService(
    port: Config.value(0),
    routes: [
      WebsocketEndpoint(
        onSession: (session) async {
          session.stream.listen((frame) {
            if (frame.opcode == WebsocketOpcode.text) {
              final text = utf8.decode(frame.payload);
              session.sink.add(WebsocketFrame.text(text));
            }
            if (frame.opcode == WebsocketOpcode.binary) {
              session.sink.add(WebsocketFrame.binary(frame.payload));
              session.sink.add(WebsocketFrame.close(4000, 'done'));
            }
          });
        },
        chooseProtocol: (List<String> protocols) {
          if (protocols.contains('test-protocol')) {
            return 'test-protocol';
          } else {
            throw ApiRequestException.badRequest('Protocol mismatch.');
          }
        },
      ),
    ],
  ),
];

void main() {
  declareTest('ApiService Upgrade Connection', testScenario, () async {
    final socket = await WebSocket.connect(
      Uri(scheme: 'ws', host: 'localhost', port: Find<Api>().find().port),
      protocols: ['wrong-protocol', 'test-protocol'],
    );

    final completer1 = Completer();
    final completer2 = Completer();
    final completer3 = Completer();
    socket.events.listen((e) async {
      switch (e) {
        case TextDataReceived(text: final text):
          log.debug('Received Text: $text');
          expect(text, 'Hello');
          completer1.complete();
        case BinaryDataReceived(data: final data):
          log.debug('Received Binary: $data');
          expect(data, [0, 1, 2, 3, 4]);
          completer2.complete();
        case CloseReceived(code: final code, reason: final reason):
          log.debug('Connection to server closed: $code [$reason]');
          expect(code, 4000);
          expect(reason, 'done');
          completer3.complete();
      }
    });

    socket.sendText('Hello');
    await completer1.future;
    socket.sendBytes([0, 1, 2, 3, 4].asUint8List());
    await completer2.future;
    await completer3.future;
  }, tags: ['api']);

  declareTest('Connection fails on protocol mismatch', testScenario, () async {
    expect(
      () async => await WebSocket.connect(Uri.parse('ws://localhost:8080')),
      throwsA(isException),
    );
  }, tags: ['api']);
}
