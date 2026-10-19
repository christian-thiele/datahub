import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
import 'package:path/path.dart' as p;

import '../http/http_headers.dart';
import '../http/http_response.dart';

/// Defines a response to a api request.
///
/// ApiResponse contains header information as well as the content data,
/// as well as the logic to transform the data into response data sent via http.
abstract class ApiResponse(var int statusCode) {
  Map<String, List<String>> getHeaders();

  Stream<List<int>> getData();

  /// Automatically creates the corresponding ApiResponse implementation for
  /// [body].
  ///
  /// Allowed types for [body] are:
  /// null, [ApiResponse], [Uint8List], [ByteData], [File],
  /// Map&lt;String, dynamic&gt;, List&lt;dynamic&gt; and [TransferObject]
  factory dynamic(dynamic body, {int statusCode = 200}) {
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

enum ContentDisposition() {
  inline,
  attachment,
}

abstract class _SynchronousResponse(super.statusCode) extends ApiResponse {
  @override
  Stream<List<int>> getData() {
    final bytes = getBytes();
    return Stream<List<int>>.fromIterable([bytes]);
  }

  List<int> getBytes();
}

class JsonResponse(
  final Object? _data, {
  int statusCode = 200,
  final Map<String, dynamic>? _headers,
}) extends _SynchronousResponse {
  this : super(statusCode);

  @override
  List<int> getBytes() {
    if (_data == null) {
      return [];
    }

    return utf8.encode(const JsonEncoder().convert(_data));
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

  new plain(this._text, {int statusCode = 200, this._headers})
    : _contentType = '${Mime.plainText};charset=utf-8',
      super(statusCode);

  new html(this._text, {int statusCode = 200, this._headers})
    : _contentType = '${Mime.html};charset=utf-8',
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

class RawResponse(
  final Uint8List _data, {
  int statusCode = 200,
  final String contentType = Mime.octetStream,
  final Map<String, dynamic>? _headers,
}) extends _SynchronousResponse {
  this : super(statusCode);

  @override
  List<int> getBytes() => _data;

  @override
  Map<String, List<String>> getHeaders() => {
    HttpHeaders.contentLength: [_data.length.toString()],
    HttpHeaders.contentType: [contentType],
    ...?_headers,
  };
}

class EmptyResponse({
  int statusCode = 200,
  final Map<String, dynamic>? _headers,
}) extends _SynchronousResponse {
  this : super(statusCode);

  @override
  List<int> getBytes() => [];

  @override
  Map<String, List<String>> getHeaders() => {...?_headers};
}

class ByteStreamResponse(
  final Stream<List<int>> _dataStream,
  final int? length, {
  int statusCode = 200,
  final String contentType = 'application/octet-stream',
  final String? fileName,
  final ContentDisposition disposition = ContentDisposition.inline,
  final Map<String, dynamic>? _headers,
}) extends ApiResponse {
  this : super(statusCode);

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

class FileResponse(
  final io.File file, {
  super.disposition = ContentDisposition.inline,
  String? contentType,
  super.headers,
}) extends ByteStreamResponse {
  this
    : super(
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
class DebugResponse(dynamic error, StackTrace stack, int statusCode)
    extends TextResponse {
  this
    : super.plain(
        'The following error occurred:\n$error\n$stack\n\nThis is a debug message. '
        'Messages like this will only be displayed in DEV mode.',
        statusCode: statusCode,
      );
}

class HeadResponse(final ApiResponse _inner) extends EmptyResponse {
  @override
  Map<String, List<String>> getHeaders() => _inner.getHeaders();
}
