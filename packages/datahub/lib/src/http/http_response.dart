import 'dart:convert';
import 'dart:io';

import 'utils.dart';

class HttpResponse {
  final Uri requestUrl;
  final int statusCode;
  final Map<String, List<String>> headers;
  final Stream<List<int>> bodyData;

  Encoding? get charset => getEncodingFromHeaders(headers);

  HttpResponse(this.requestUrl, this.statusCode, this.headers, this.bodyData);
}

/// [HttpResponse] for hijacking the underlying socket.
/// Use for protocols that upgrade from HTTP (like websocket).
class UpgradeHttpResponse extends HttpResponse {
  final void Function(Socket) socketHandler;

  UpgradeHttpResponse(
    Uri requestUrl,
    Map<String, List<String>> headers,
    this.socketHandler,
  ) : super(requestUrl, 101, {
        'Connection': ['Upgrade'],
        ...headers,
      }, Stream<List<int>>.empty());
}
