import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

import 'package:cryptography/cryptography.dart' as cryptography;
import 'api_route.dart';
import 'api_request.dart';
import 'websocket_response.dart';
import 'websocket_frame.dart';

class WebsocketEndpoint extends ApiEndpoint {
  final String Function(List<String> protocols) chooseProtocol;
  final void Function(WebsocketSession) onSession;

  const WebsocketEndpoint({
    super.matcher,
    required this.onSession,
    required this.chooseProtocol,
  });

  @override
  Future<dynamic> onRequest(ApiRequest request) async {
    if (request.method != HttpRequestMethod.get) {
      throw ApiRequestException.methodNotAllowed();
    }

    if (request.headers['connection']?.singleOrNull != 'Upgrade') {
      throw ApiRequestException.badRequest();
    }

    if (request.headers['upgrade']?.singleOrNull != 'websocket') {
      throw ApiRequestException.badRequest();
    }

    if (request.headers['sec-websocket-version']?.singleOrNull != '13') {
      throw ApiRequestException.badRequest();
    }

    final webSocketKey =
        switch (request.headers['sec-websocket-key']?.singleOrNull) {
          final String key => key,
          _ => throw ApiRequestException.badRequest(),
        };

    final protocol = chooseProtocol(
      switch (request.headers['sec-websocket-protocol']) {
        [final protocol, ...] =>
          protocol.split(',').map((e) => e.trim()).toList(),
        _ => [],
      },
    );

    final acceptKeyInput =
        '$webSocketKey'
        '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
    final acceptKeyHash = await cryptography.Sha1().hash(
      utf8.encode(acceptKeyInput),
    );
    final acceptKey = base64Encode(acceptKeyHash.bytes);

    return WebsocketResponse(
      acceptKey: acceptKey,
      protocol: protocol,
      onSocket: (socket) {
        onSession(
          WebsocketSession(
            initialRequest: request,
            socket: socket,
            acceptKey: acceptKey,
            protocol: protocol,
          ),
        );
      },
    );
  }
}

class WebsocketSession {
  final ApiRequest initialRequest;
  final String acceptKey;
  final String protocol;
  final io.Socket socket;

  final _sinkController = StreamController<WebsocketFrame>();

  WebsocketSession({
    required this.initialRequest,
    required this.acceptKey,
    required this.protocol,
    required this.socket,
  }) {
    _sinkController.stream
        .transform(const WebsocketFrameEncoder())
        .listen(socket.add, onDone: socket.close, onError: (_) => socket.close());
  }

  Stream<WebsocketFrame> get frames =>
      socket.map((data) => Uint8List.fromList(data)).transform(const WebsocketFrameDecoder());

  StreamSink<WebsocketFrame> get sink => _sinkController.sink;
}
