import 'dart:async';
import 'dart:io';

import 'package:datahub/api.dart';
import 'package:datahub/src/http/http_response.dart';

class WebsocketResponse({
  required final void Function(Socket) onSocket,
  required final String acceptKey,
  final String? protocol,
}) extends ApiResponse {
  this : super(101);

  @override
  Stream<List<int>> getData() => const Stream.empty();

  @override
  Map<String, List<String>> getHeaders() => {
    'Upgrade': ['websocket'],
    'Connection': ['Upgrade'],
    'Sec-WebSocket-Accept': [acceptKey],
    if (protocol case final protocol?) 'Sec-WebSocket-Protocol': [protocol],
  };

  @override
  HttpResponse toHttpResponse(Uri requestUrl) =>
      UpgradeHttpResponse(requestUrl, getHeaders(), onSocket);
}
