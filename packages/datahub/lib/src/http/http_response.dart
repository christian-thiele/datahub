import 'dart:convert';
import 'dart:io';

import 'utils.dart';

class HttpResponse(
  final Uri requestUrl,
  final int statusCode,
  final Map<String, List<String>> headers,
  final Stream<List<int>> bodyData,
) {
  Encoding? get charset => getEncodingFromHeaders(headers);
}

/// [HttpResponse] for hijacking the underlying socket.
/// Use for protocols that upgrade from HTTP (like websocket).
class UpgradeHttpResponse(
  Uri requestUrl,
  Map<String, List<String>> headers,
  final void Function(Socket) socketHandler,
) extends HttpResponse {
  this
    : super(requestUrl, 101, {
        'Connection': ['Upgrade'],
        ...headers,
      }, const Stream<List<int>>.empty());
}
