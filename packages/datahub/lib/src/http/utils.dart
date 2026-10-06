import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:http2/http2.dart' as http2;

import 'http_headers.dart';

final charsetRegExp = RegExp(
  r'^\s*(charset|encoding)\s*=\s*"?([^";,\s]+)',
  caseSensitive: false,
);

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

/// Splits into $1 Pseudo Headers and $2 HTTP Headers
///
/// Each header field becomes one value, like for HTTP/1.1 requests. Multiple
/// `cookie` fields are concatenated into one, as required by RFC 9113
/// (section 8.2.3).
(Map<String, String>, Map<String, List<String>>) http2Headers(
  List<http2.Header> headers,
) {
  final rawHeaders = headers.map(
    (e) => MapEntry(utf8.decode(e.name), utf8.decode(e.value)),
  );

  final decodedHeaders = rawHeaders.split((h) => h.key.startsWith(':'));
  final pseudoHeaders = Map.fromEntries(decodedHeaders.$1);

  final httpHeaders = <String, List<String>>{};
  for (final MapEntry(:key, :value) in decodedHeaders.$2) {
    final values = httpHeaders.putIfAbsent(key, () => []);
    if (key == HttpHeaders.cookie && values.isNotEmpty) {
      values.first = '${values.first}; $value';
    } else {
      values.add(value);
    }
  }

  return (pseudoHeaders, httpHeaders);
}

Encoding? getEncodingFromHeaders(Map<String, List<String>> headers) {
  if (headers.containsKey(HttpHeaders.contentType)) {
    final contentType = headers[HttpHeaders.contentType]!.first;
    final parts = contentType.split(';');
    final charsetMatch = parts
        .map((p) => charsetRegExp.firstMatch(p))
        .nonNulls
        .firstOrNull;

    return Encoding.getByName(charsetMatch?.group(2));
  } else {
    return null;
  }
}
