import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:datahub_redis/src/protocol/resp_parser.dart';

/// Handles a command received by [FakeRedisServer].
///
/// Returns the raw RESP response to write, or null to not respond.
typedef FakeCommandHandler =
    String? Function(List<String> command, FakeClient client);

/// Minimal in-process server that parses RESP commands and lets tests decide
/// what to respond, to provoke situations a real server does not produce.
class FakeRedisServer {
  final ServerSocket _server;
  final FakeCommandHandler handler;
  final clients = <FakeClient>[];

  /// All commands received, in order.
  final commands = <List<String>>[];

  FakeRedisServer._(this._server, this.handler) {
    _server.listen((socket) => clients.add(FakeClient._(socket, this)));
  }

  static Future<FakeRedisServer> start(FakeCommandHandler handler) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    return FakeRedisServer._(server, handler);
  }

  int get port => _server.port;

  /// Waits until a client is connected and returns the first one.
  Future<FakeClient> firstClient() async {
    while (clients.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    return clients.first;
  }

  Future<void> close() async {
    await _server.close();
    for (final client in clients) {
      client.socket.destroy();
    }
  }
}

class FakeClient {
  final Socket socket;
  final FakeRedisServer _server;
  final _parser = RespParser();

  /// Number of data chunks received from the client.
  var chunks = 0;

  /// Whether data was received that is not RESP (e.g. a TLS handshake).
  var receivedGarbage = false;

  FakeClient._(this.socket, this._server) {
    socket.listen(_onData, onError: (_) {}, cancelOnError: true);
    socket.done.ignore();
  }

  void _onData(Uint8List data) {
    chunks++;
    if (receivedGarbage) {
      return;
    }
    _parser.add(data);
    try {
      for (var reply = _parser.next(); reply != null; reply = _parser.next()) {
        final command = [for (final item in reply.asList!) item.asString!];
        _server.commands.add(command);
        if (_server.handler(command, this) case final response?) {
          write(response);
        }
      }
    } on RespProtocolException {
      receivedGarbage = true;
    }
  }

  void write(String response) {
    try {
      socket.add(utf8.encode(response));
    } on StateError {
      // closed by the client
    }
  }
}

/// Responds like a server without authentication: `+OK` to everything,
/// `+PONG` to PING.
String? okHandler(List<String> command, FakeClient client) =>
    switch (command.first) {
      'PING' => '+PONG\r\n',
      _ => '+OK\r\n',
    };
