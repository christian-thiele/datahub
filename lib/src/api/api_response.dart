import 'dart:convert';
import 'dart:io';

import 'package:cl_datahub/utils.dart';

//TODO files, bytedata etc.

/// Defines a response to a api request.
///
/// ApiResponse contains header information as well as the content data,
/// as well as the logic to transform the data into response data sent via http.
abstract class ApiResponse {
  Map<String, String> getHeaders();

  List<int> getData();

  ApiResponse();

  factory ApiResponse.dynamic(dynamic body) {
    if (body == null) {
      return EmptyResponse();
    } else if (body is Map<String, dynamic> || body is List<dynamic>) {
      return JsonResponse(body);
    } else {
      return TextResponse.plain(body.toString());
    }
  }
}

class JsonResponse extends ApiResponse {
  final Object? _data;

  JsonResponse(this._data);

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

  TextResponse.plain(this._text) : _contentType = 'text/plain;charset=utf-8';

  TextResponse.html(this._text) : _contentType = 'text/html;charset=utf-8';

  @override
  List<int> getData() => utf8.encode(_text);

  @override
  Map<String, String> getHeaders() {
    return {HttpHeaders.contentTypeHeader: _contentType};
  }
}

class EmptyResponse extends ApiResponse {
  @override
  List<int> getData() => [];

  @override
  Map<String, String> getHeaders() => {};
}
