import 'dart:convert';

import 'utils.dart';

class HttpResponse {
  final Uri requestUrl;
  final int statusCode;
  final Map<String, List<String>> headers;
  final Stream<List<int>> bodyData;

  Encoding? get charset => getEncodingFromHeaders(headers);

  HttpResponse(this.requestUrl, this.statusCode, this.headers, this.bodyData);
}
