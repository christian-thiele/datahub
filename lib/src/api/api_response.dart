import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cl_datahub/cl_datahub.dart';

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
    } else if (body is ApiResponse) {
      return body;
    } else if (body is Uint8List) {
      return RawResponse(body);
    } else if (body is ByteData) {
      return RawResponse(body.buffer.asUint8List());
    } else if (body is Map<String, dynamic> ||
        body is List<dynamic> ||
        body is TransferObject) {
      return JsonResponse(body, statusCode);
    } else {
      return TextResponse.plain(body.toString(), statusCode);
    }
    //TODO File would be cool here (automatic content-type and stuff)
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

class RawResponse extends ApiResponse {
  final String contentType;
  final Uint8List _data;

  RawResponse(this._data,
      {int statusCode = 200, this.contentType = 'application/octet-stream'})
      : super(statusCode);

  @override
  List<int> getData() => _data;

  @override
  Map<String, String> getHeaders() =>
      {'content-length': _data.length.toString(), 'content-type': contentType};
}

class EmptyResponse extends ApiResponse {
  EmptyResponse([int statusCode = 200]) : super(statusCode);

  @override
  List<int> getData() => [];

  @override
  Map<String, String> getHeaders() => {};
}
