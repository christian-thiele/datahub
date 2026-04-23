import 'dart:async';
import 'dart:convert';
import 'package:cryptography/dart.dart';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

import 'api_route.dart';
import 'api_request.dart';
import 'websocket_response.dart';
import 'websocket_session.dart';

class WebsocketEndpoint extends ApiEndpoint {
  final String Function(List<String> protocols) chooseProtocol;
  final void Function(WebsocketSession) onSession;
  final Duration? heartbeatInterval;
  final Duration heartbeatTimeout;

  const WebsocketEndpoint({
    super.matcher,
    required this.onSession,
    required this.chooseProtocol,
    this.heartbeatInterval,
    this.heartbeatTimeout = const Duration(seconds: 30),
  });

  static bool isWebsocketUpgradeRequest(ApiRequest request) {
    if (request.method != HttpRequestMethod.get) {
      return false;
    }

    if (request.headers['connection']?.singleOrNull != 'Upgrade') {
      return false;
    }

    if (request.headers['upgrade']?.singleOrNull != 'websocket') {
      return false;
    }

    if (request.headers['sec-websocket-version']?.singleOrNull != '13') {
      return false;
    }

    if (request.headers['sec-websocket-key']?.singleOrNull == null) {
      return false;
    }

    return true;
  }

  static String buildAcceptKey(ApiRequest request) {
    final webSocketKey =
        switch (request.headers['sec-websocket-key']?.singleOrNull) {
          final String key => key,
          _ => throw ApiRequestException.badRequest(),
        };

    final acceptKeyInput =
        '$webSocketKey'
        '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
    final acceptKeyHash = const DartSha1().hashSync(
      utf8.encode(acceptKeyInput),
    );
    return base64Encode(acceptKeyHash.bytes);
  }

  @override
  Future<dynamic> onRequest(ApiRequest request) async {
    if (request.method != HttpRequestMethod.get) {
      throw ApiRequestException.methodNotAllowed();
    }

    if (!isWebsocketUpgradeRequest(request)) {
      throw ApiRequestException.badRequest();
    }

    final protocol = chooseProtocol(
      switch (request.headers['sec-websocket-protocol']) {
        [final protocol, ...] =>
          protocol.split(',').map((e) => e.trim()).toList(),
        _ => [],
      },
    );

    final acceptKey = buildAcceptKey(request);

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
            heartbeatInterval: heartbeatInterval,
            heartbeatTimeout: heartbeatTimeout,
          ),
        );
      },
    );
  }
}
