import 'dart:convert';
import 'dart:io';

import 'package:cl_datahub/utils.dart';

//TODO files, bytedata etc.

/// Defines a response to a api request.
///
/// ApiResponse contains header information as well as the content data,
/// as well as the logic to transform the data into response data sent via http.
abstract class ApiResponse {
  int statusCode;

  Map<String, String> getHeaders();

  List<int> getData();

  ApiResponse(this.statusCode);

  factory ApiResponse.dynamic(dynamic body, [int statusCode = 200]) {
    if (body == null) {
      return EmptyResponse(statusCode);
    } else if (body is Map<String, dynamic> || body is List<dynamic>) {
      return JsonResponse(body, statusCode);
    } else {
      return TextResponse.plain(body.toString(), statusCode);
    }
  }
}

class JsonResponse extends ApiResponse {
  final Object? _data;

  JsonResponse(this._data, [int statusCode = 200]) : super(statusCode);

  @override
  List<int> getData() {
    if (_data == null) {
      return [];
    }

    return utf8.encode(JsonEncoder(customJsonEncode).convert(_data!));
  }

  @override
  Map<String, String> getHeaders() {
    return {HttpHeaders.contentTypeHeader: 'application/json;encoding=utf-8'};
  }
}

class TextResponse extends ApiResponse {
  final String _text;
  final String _contentType;

  TextResponse.plain(this._text, [int statusCode = 200])
      : _contentType = 'text/plain;charset=utf-8',
        super(statusCode);

  TextResponse.html(this._text, [int statusCode = 200])
      : _contentType = 'text/html;charset=utf-8',
        super(statusCode);

  @override
  List<int> getData() => utf8.encode(_text);

  @override
  Map<String, String> getHeaders() {
    return {HttpHeaders.contentTypeHeader: _contentType};
  }
}

class EmptyResponse extends ApiResponse {
  EmptyResponse([int statusCode = 200]) : super(statusCode);

  @override
  List<int> getData() => [];

  @override
  Map<String, String> getHeaders() => {};
}
