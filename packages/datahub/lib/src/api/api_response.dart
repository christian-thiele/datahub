import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:path/path.dart' as p;

import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

import '../http/http_headers.dart';
import '../http/http_response.dart';

/// Defines a response to a api request.
///
/// ApiResponse contains header information as well as the content data,
/// as well as the logic to transform the data into response data sent via http.
abstract class ApiResponse {
  int statusCode;

  Map<String, List<String>> getHeaders();

  Stream<List<int>> getData();

  ApiResponse(this.statusCode);

  /// Automatically creates the corresponding ApiResponse implementation for
  /// [body].
  ///
  /// Allowed types for [body] are:
  /// null, [ApiResponse], [Uint8List], [ByteData], [File],
  /// Map&lt;String, dynamic&gt;, List&lt;dynamic&gt; and [TransferObject]
  factory ApiResponse.dynamic(dynamic body, {int statusCode = 200}) {
    if (body == null) {
      return EmptyResponse(statusCode: statusCode);
    } else if (body is ApiResponse) {
      return body;
    } else if (body is Uint8List) {
      return RawResponse(body);
    } else if (body is ByteData) {
      return RawResponse(body.buffer.asUint8List());
    } else if (body is io.File) {
      return FileResponse(body);
    } else if (body is Map<String, dynamic> ||
        body is List<dynamic> ||
        body is DataObject) {
      return JsonResponse(body, statusCode: statusCode);
    } else if (body is Stream<List<int>>) {
      throw ApiError(
        'A data stream cannot be used as response type without a length argument.'
        'Use ByteStreamResponse or FileResponse as return type instead to provide the length.',
      );
    } else {
      return TextResponse.plain(body.toString(), statusCode: statusCode);
    }
  }

  HttpResponse toHttpResponse(Uri requestUrl) =>
      HttpResponse(requestUrl, statusCode, getHeaders(), getData());
}

enum ContentDisposition { inline, attachment }

abstract class _SynchronousResponse extends ApiResponse {
  _SynchronousResponse(super.statusCode);

  @override
  Stream<List<int>> getData() {
    final bytes = getBytes();
    return Stream<List<int>>.fromIterable([bytes]);
  }

  List<int> getBytes();
}

class JsonResponse extends _SynchronousResponse {
  final Object? _data;
  final Map<String, dynamic>? _headers;

  JsonResponse(
    this._data, {
    int statusCode = 200,
    Map<String, dynamic>? headers,
  }) : _headers = headers,
       super(statusCode);

  @override
  List<int> getBytes() {
    if (_data == null) {
      return [];
    }

    return utf8.encode(JsonEncoder().convert(_data));
  }

  @override
  Map<String, List<String>> getHeaders() {
    return {
      HttpHeaders.contentType: ['${Mime.json};charset=utf-8'],
      ...?_headers,
    };
  }
}

class TextResponse extends _SynchronousResponse {
  final String _text;
  final String _contentType;
  final Map<String, dynamic>? _headers;

  TextResponse.plain(
    this._text, {
    int statusCode = 200,
    Map<String, dynamic>? headers,
  }) : _contentType = '${Mime.plainText};charset=utf-8',
       _headers = headers,
       super(statusCode);

  TextResponse.html(
    this._text, {
    int statusCode = 200,
    Map<String, dynamic>? headers,
  }) : _contentType = '${Mime.html};charset=utf-8',
       _headers = headers,
       super(statusCode);

  @override
  List<int> getBytes() => utf8.encode(_text);

  @override
  Map<String, List<String>> getHeaders() {
    return {
      HttpHeaders.contentType: [_contentType],
      ...?_headers,
    };
  }
}

class RawResponse extends _SynchronousResponse {
  final String contentType;
  final Uint8List _data;
  final Map<String, dynamic>? _headers;

  RawResponse(
    this._data, {
    int statusCode = 200,
    this.contentType = Mime.octetStream,
    Map<String, dynamic>? headers,
  }) : _headers = headers,
       super(statusCode);

  @override
  List<int> getBytes() => _data;

  @override
  Map<String, List<String>> getHeaders() => {
    HttpHeaders.contentLength: [_data.length.toString()],
    HttpHeaders.contentType: [contentType],
    ...?_headers,
  };
}

class EmptyResponse extends _SynchronousResponse {
  final Map<String, dynamic>? _headers;

  EmptyResponse({int statusCode = 200, Map<String, dynamic>? headers})
    : _headers = headers,
      super(statusCode);

  @override
  List<int> getBytes() => [];

  @override
  Map<String, List<String>> getHeaders() => {...?_headers};
}

class ByteStreamResponse extends ApiResponse {
  final String contentType;
  final ContentDisposition disposition;
  final String? fileName;
  final Stream<List<int>> _dataStream;
  final int? length;
  final Map<String, dynamic>? _headers;

  ByteStreamResponse(
    this._dataStream,
    this.length, {
    int statusCode = 200,
    this.contentType = 'application/octet-stream',
    this.fileName,
    this.disposition = ContentDisposition.inline,
    Map<String, dynamic>? headers,
  }) : _headers = headers,
       super(statusCode);

  @override
  Stream<List<int>> getData() => _dataStream;

  @override
  Map<String, List<String>> getHeaders() => {
    if (length != null) HttpHeaders.contentLength: [length.toString()],
    HttpHeaders.contentType: [contentType],
    if (nullOrEmpty(fileName)) 'content-disposition': [disposition.name],
    if (!nullOrEmpty(fileName))
      'content-disposition': ['${disposition.name};filename="$fileName"'],
    ...?_headers,
  };
}

class FileResponse extends ByteStreamResponse {
  final io.File file;

  FileResponse(
    this.file, {
    super.disposition = ContentDisposition.inline,
    String? contentType,
    super.headers,
  }) : super(
         file.openRead(),
         file.lengthSync(),
         fileName: p.basename(file.path),
         contentType:
             contentType ??
             Mime.fromExtension(p.extension(file.path)) ??
             Mime.octetStream,
       );
}

//TODO nicer debug message
class DebugResponse extends TextResponse {
  DebugResponse(dynamic error, StackTrace stack, int statusCode)
    : super.plain(
        'The following error occurred:\n$error\n$stack\n\nThis is a debug message. '
        'Messages like this will only be displayed in DEV mode.',
        statusCode: statusCode,
      );
}

class HeadResponse extends EmptyResponse {
  final ApiResponse _inner;

  HeadResponse(this._inner);

  @override
  Map<String, List<String>> getHeaders() => _inner.getHeaders();
}
