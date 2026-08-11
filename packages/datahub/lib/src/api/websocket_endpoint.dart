import 'dart:async';
import 'dart:convert';

import 'package:cryptography/dart.dart';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

import 'api_request.dart';
import 'api_route.dart';
import 'websocket_frame.dart';
import 'websocket_response.dart';
import 'websocket_session.dart';

class WebsocketEndpoint extends ApiEndpoint {
  /// Selects the subprotocol from the ones offered by the client.
  ///
  /// Returning null omits the `Sec-WebSocket-Protocol` response header
  /// (no subprotocol). A non-null return value must be one of the
  /// offered protocols. Throw an [ApiRequestException] to reject the
  /// connection.
  final String? Function(List<String> protocols) chooseProtocol;
  final void Function(WebsocketSession) onSession;
  final Duration? heartbeatInterval;
  final Duration heartbeatTimeout;
  final int maxFrameSize;

  const WebsocketEndpoint({
    super.matcher,
    required this.onSession,
    this.chooseProtocol = _noProtocol,
    this.heartbeatInterval,
    this.heartbeatTimeout = const Duration(seconds: 30),
    this.maxFrameSize = WebsocketFrameDecoder.defaultMaxFrameSize,
  });

  static String? _noProtocol(List<String> protocols) => null;

  /// Whether [header] contains [token] in any of its comma-separated
  /// values, compared case-insensitively (RFC 7230 list syntax).
  static bool _headerContainsToken(List<String>? header, String token) =>
      header?.any(
        (value) =>
            value.split(',').map((e) => e.trim().toLowerCase()).contains(token),
      ) ??
      false;

  static bool isWebsocketUpgradeRequest(ApiRequest request) {
    if (request.method != HttpRequestMethod.get) {
      return false;
    }

    if (!_headerContainsToken(request.headers['connection'], 'upgrade')) {
      return false;
    }

    if (!_headerContainsToken(request.headers['upgrade'], 'websocket')) {
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

    final offeredProtocols =
        request.headers['sec-websocket-protocol']
            ?.expand((value) => value.split(','))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];

    final protocol = chooseProtocol(offeredProtocols);
    if (protocol != null && !offeredProtocols.contains(protocol)) {
      throw ApiException(
        'chooseProtocol returned a protocol that was not offered '
        'by the client: $protocol',
      );
    }

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
            maxFrameSize: maxFrameSize,
          ),
        );
      },
    );
  }
}
