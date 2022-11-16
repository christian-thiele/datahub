import 'dart:convert';
import 'dart:io' as io;
import 'package:http2/http2.dart' as http2;
import 'package:boost/boost.dart';

import 'http_headers.dart';

late final charsetRegExp = RegExp(r'(charset|encoding)=([^;,\n]+)');

Map<String, List<String>> http1Headers(io.HttpHeaders headers) {
  final map = <String, List<String>>{};
  headers.forEach((name, values) => map[name] = values);
  return map;
}

/// Splits into [a] Pseudo Headers and [b] HTTP Headers
Tuple<Map<String, String>, Map<String, List<String>>> http2Headers(
    List<http2.Header> headers) {
  final rawHeaders =
      headers.map((e) => MapEntry(utf8.decode(e.name), utf8.decode(e.value)));
  final decodedHeaders = rawHeaders.split((h) => h.key.startsWith(':'));
  final pseudoHeaders = Map.fromEntries(decodedHeaders.a);
  final httpHeaders = Map.fromEntries(decodedHeaders.b.map((e) =>
      MapEntry(e.key, e.value.split(',').map((e) => e.trim()).toList())));
  return Tuple(pseudoHeaders, httpHeaders);
}

Encoding? getEncodingFromHeaders(Map<String, List<String>> headers) {
  if (headers.containsKey(HttpHeaders.contentType)) {
    final contentType = headers[HttpHeaders.contentType]!.first;
    final parts = contentType.split(';');
    final charsetMatch =
        parts.map((p) => charsetRegExp.firstMatch(p)).whereNotNull.firstOrNull;

    return Encoding.getByName(charsetMatch?.group(1));
  } else {
    return null;
  }
}
