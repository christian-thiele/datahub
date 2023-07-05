import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:http2/http2.dart' as http2;

import 'utils.dart';

class HttpRequest {
  final ApiRequestMethod method;
  final Uri requestUri;
  final Map<String, List<String>> headers;
  final Stream<List<int>> bodyData;

  String get path => nullOrWhitespace(requestUri.path) ? '/' : requestUri.path;
  Map<String, List<String>> get queryParams => requestUri.queryParametersAll;

  Encoding? get charset => getEncodingFromHeaders(headers);

  HttpRequest(
    this.method,
    this.requestUri,
    this.headers,
    this.bodyData,
  );

  factory HttpRequest.http1(io.HttpRequest request) {
    return HttpRequest(
      parseMethod(request.method),
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

    if (!headers.a.containsKey(':method') || !headers.a.containsKey(':path')) {
      throw Exception('Invalid header message.');
    }

    final path = Uri.parse(headers.a[':path']!);

    return HttpRequest(
      parseMethod(headers.a[':method']!),
      path,
      headers.b,
      data,
    );
  }
}
