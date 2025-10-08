import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:http2/http2.dart' as http2;

import 'http_request_method.dart';
import 'utils.dart';

class HttpRequest {
  final HttpRequestMethod method;
  final Uri requestUri;
  final Map<String, List<String>> headers;
  final Stream<List<int>> bodyData;

  String get path => nullOrWhitespace(requestUri.path) ? '/' : requestUri.path;

  Map<String, List<String>> get queryParams => requestUri.queryParametersAll;

  Encoding? get charset => getEncodingFromHeaders(headers);

  HttpRequest(this.method, this.requestUri, this.headers, this.bodyData);

  factory HttpRequest.http1(io.HttpRequest request) {
    return HttpRequest(
      HttpRequestMethod.parse(request.method),
      request.uri,
      http1Headers(request.headers),
      request,
    );
  }

  factory HttpRequest.http2(
    http2.HeadersStreamMessage headerMessage,
    Stream<List<int>> data,
  ) {
    final headers = http2Headers(headerMessage.headers);

    if (!headers.$1.containsKey(':method') ||
        !headers.$1.containsKey(':path')) {
      throw Exception('Invalid header message.');
    }

    final path = Uri.parse(headers.$1[':path']!);

    return HttpRequest(
      HttpRequestMethod.parse(headers.$1[':method']!),
      path,
      headers.$2,
      data,
    );
  }
}
