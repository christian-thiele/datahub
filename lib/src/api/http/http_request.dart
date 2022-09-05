import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:http2/http2.dart' as http2;

class HttpRequest {
  final ApiRequestMethod method;
  final String path;
  final Map<String, List<String>> headers;
  final Map<String, String> queryParams;
  final Stream<List<int>> bodyData;

  HttpRequest(
    this.method,
    this.path,
    this.headers,
    this.queryParams,
    this.bodyData,
  );

  factory HttpRequest.http1(io.HttpRequest request) {
    return HttpRequest(
      parseMethod(request.method),
      request.uri.path,
      _http1Headers(request.headers),
      request.uri.queryParameters,
      request,
    );
  }

  factory HttpRequest.http2(
    http2.HeadersStreamMessage headerMessage,
    Stream<List<int>> data,
  ) {
    final headers = _http2Headers(headerMessage.headers);

    if (!headers.a.containsKey(':method') || !headers.a.containsKey(':path')) {
      throw Exception('Invalid header message.');
    }

    final path = Uri.parse(headers.a[':path']!);

    return HttpRequest(
      parseMethod(headers.a[':method']!),
      path.path,
      headers.b,
      path.queryParameters,
      data,
    );
  }

  static Map<String, List<String>> _http1Headers(io.HttpHeaders headers) {
    final map = <String, List<String>>{};
    headers.forEach((name, values) => map[name] = values);
    return map;
  }

  static Tuple<Map<String, String>, Map<String, List<String>>> _http2Headers(
      List<http2.Header> headers) {
    final rawHeaders =
        headers.map((e) => MapEntry(utf8.decode(e.name), utf8.decode(e.value)));
    final decodedHeaders = rawHeaders.split((h) => h.key.startsWith(':'));
    final pseudoHeaders = Map.fromEntries(decodedHeaders.a);
    final httpHeaders = Map.fromEntries(decodedHeaders.b.map((e) =>
        MapEntry(e.key, e.value.split(',').map((e) => e.trim()).toList())));
    return Tuple(pseudoHeaders, httpHeaders);
  }
}
