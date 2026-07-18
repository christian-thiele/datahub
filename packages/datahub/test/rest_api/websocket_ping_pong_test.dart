import 'dart:async';
import 'dart:io' as io;

import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/expect.dart';

void main() {
  declareTest(
    'Websocket Ping-Pong',
    [
      ApiService(
        routes: [
          WebsocketEndpoint(
            onSession: (session) {
              session.stream.listen((event) {});
            },
            chooseProtocol: (protocols) => protocols.firstOrNull ?? '',
            heartbeatInterval: const Duration(milliseconds: 200),
            heartbeatTimeout: const Duration(milliseconds: 500),
          ),
        ],
      ),
    ],
    () async {
      final socket = await io.Socket.connect('localhost', 8080);
      final broadcastSocket = socket.asBroadcastStream();

      // Minimal websocket handshake
      socket.write(
        'GET / HTTP/1.1\r\n'
        'Host: localhost:8080\r\n'
        'Upgrade: websocket\r\n'
        'Connection: Upgrade\r\n'
        'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n'
        'Sec-WebSocket-Version: 13\r\n'
        '\r\n',
      );

      final pings = <WebsocketFrame>[];
      final doneCompleter = Completer();

      final encoder = const WebsocketFrameEncoder();

      final subscription = broadcastSocket.listen(
        (data) {
          // Manual check for PING frame (0x89 0x00)
          if (data.length >= 2 && data[0] == 0x89 && data[1] == 0x00) {
            pings.add(WebsocketFrame.ping());
            if (pings.length <= 2) {
              socket.add(encoder.encodeFrame(WebsocketFrame.pong()));
            }
          }
        },
        onDone: () {
          if (!doneCompleter.isCompleted) {
            doneCompleter.complete();
          }
        },
      );

      // Wait for some time to allow multiple pings
      await Future.delayed(const Duration(milliseconds: 800));

      expect(
        pings.length,
        greaterThanOrEqualTo(2),
        reason: 'Should have received at least 2 pings and responded to them',
      );
      expect(
        doneCompleter.isCompleted,
        isFalse,
        reason: 'Connection should still be open because we responded to pings',
      );

      // Now stop responding and wait for timeout
      await doneCompleter.future.timeout(const Duration(seconds: 2));

      expect(
        pings.length,
        greaterThan(2),
        reason: 'Should have received more pings before timeout',
      );
      expect(
        doneCompleter.isCompleted,
        isTrue,
        reason: 'Connection should be closed after heartbeat timeout',
      );

      await subscription.cancel();
    },
    tags: ['api'],
  );
}
