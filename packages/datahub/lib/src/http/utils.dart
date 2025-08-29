import 'dart:convert';
import 'dart:io' as io;
import 'package:http2/http2.dart' as http2;
import 'package:boost/boost.dart';

import 'http_headers.dart';

late final charsetRegExp = RegExp(r'(charset|encoding)=([^;,\n]+)');
late final headerValueRegExp = RegExp(r'(?:[^;"]|"(?:\\.|[^"])*")+');

Map<String, List<String>> http1Headers(io.HttpHeaders headers) {
  final map = <String, List<String>>{};
  headers.forEach((name, values) {
    if (!map.containsKey(name)) {
      map[name] = [];
    }
    map[name]!.addAll(values);
  });
  return map;
}

/// Splits into [a] Pseudo Headers and [b] HTTP Headers
Tuple<Map<String, String>, Map<String, List<String>>> http2Headers(
    List<http2.Header> headers) {
  final rawHeaders =
      headers.map((e) => MapEntry(utf8.decode(e.name), utf8.decode(e.value)));

  final decodedHeaders = rawHeaders.split((h) => h.key.startsWith(':'));
  final pseudoHeaders = Map.fromEntries(decodedHeaders.a);

  final httpHeaders = <String, List<String>>{};
  for (final entry in decodedHeaders.b) {
    if (!httpHeaders.containsKey(entry.key)) {
      httpHeaders[entry.key] = [];
    }
    final values = headerValueRegExp
        .allMatches(entry.value)
        .map((e) => e.group(0)!.trim());
    httpHeaders[entry.key]!.addAll(values);
  }

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
