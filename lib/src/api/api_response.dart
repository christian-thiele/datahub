import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/http.dart';
import 'package:path/path.dart' as p;

import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

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
  /// Map<String, dynamic>, List<dynamic> and [TransferObject]
  factory ApiResponse.dynamic(dynamic body,
      {TransferBean? bean, int statusCode = 200}) {
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
        body is TransferObjectBase) {
      return JsonResponse(body, statusCode);
    } else if (body is Stream<List<int>>) {
      throw ApiError(
          'A data stream cannot be used as response type without a length argument.'
          'Use ByteStreamResponse or FileResponse as return type instead to provide the length.');
    } else {
      return TextResponse.plain(body.toString(), statusCode: statusCode);
    }
  }

  HttpResponse toHttpResponse(Uri requestUrl) =>
      HttpResponse(requestUrl, statusCode, getHeaders(), getData());
}

enum ContentDisposition { inline, attachment }

abstract class _SynchronousResponse extends ApiResponse {
  _SynchronousResponse(int statusCode) : super(statusCode);

  @override
  Stream<List<int>> getData() {
    final bytes = getBytes();
    return Stream<List<int>>.fromIterable([bytes]);
  }

  List<int> getBytes();
}

class JsonResponse extends _SynchronousResponse {
  final Object? _data;

  JsonResponse(this._data, [int statusCode = 200]) : super(statusCode);

  @override
  List<int> getBytes() {
    if (_data == null) {
      return [];
    }

    return utf8.encode(JsonEncoder().convert(_data!));
  }

  @override
  Map<String, List<String>> getHeaders() {
    return {
      HttpHeaders.contentType: ['${Mime.json};encoding=utf-8']
    };
  }
}

class TextResponse extends _SynchronousResponse {
  final String _text;
  final String _contentType;

  TextResponse.plain(this._text, {int statusCode = 200})
      : _contentType = '${Mime.plainText};charset=utf-8',
        super(statusCode);

  TextResponse.html(this._text, {int statusCode = 200})
      : _contentType = '${Mime.html};charset=utf-8',
        super(statusCode);

  @override
  List<int> getBytes() => utf8.encode(_text);

  @override
  Map<String, List<String>> getHeaders() {
    return {
      HttpHeaders.contentType: [_contentType]
    };
  }
}

class RawResponse extends _SynchronousResponse {
  final String contentType;
  final Uint8List _data;

  RawResponse(this._data,
      {int statusCode = 200, this.contentType = Mime.octetStream})
      : super(statusCode);

  @override
  List<int> getBytes() => _data;

  @override
  Map<String, List<String>> getHeaders() => {
        HttpHeaders.contentLength: [_data.length.toString()],
        HttpHeaders.contentType: [contentType],
      };
}

class EmptyResponse extends _SynchronousResponse {
  EmptyResponse({int statusCode = 200}) : super(statusCode);

  @override
  List<int> getBytes() => [];

  @override
  Map<String, List<String>> getHeaders() => {};
}

class ByteStreamResponse extends ApiResponse {
  final String contentType;
  final ContentDisposition disposition;
  final String? fileName;
  final Stream<List<int>> _dataStream;
  final int? length;

  ByteStreamResponse(
    this._dataStream,
    this.length, {
    int statusCode = 200,
    this.contentType = 'application/octet-stream',
    this.fileName,
    this.disposition = ContentDisposition.inline,
  }) : super(statusCode);

  @override
  Stream<List<int>> getData() => _dataStream;

  @override
  Map<String, List<String>> getHeaders() => {
        if (length != null) HttpHeaders.contentLength: [length.toString()],
        HttpHeaders.contentType: [contentType],
        if (nullOrEmpty(fileName))
          'content-disposition': ['${disposition.name}'],
        if (!nullOrEmpty(fileName))
          'content-disposition': ['${disposition.name};filename="$fileName"'],
      };
}

class FileResponse extends ByteStreamResponse {
  final io.File file;

  FileResponse(
    this.file, {
    ContentDisposition disposition = ContentDisposition.inline,
    String? contentType,
  }) : super(
          file.openRead(),
          file.lengthSync(),
          fileName: p.basename(file.path),
          disposition: disposition,
          contentType:
              Mime.fromExtension(p.extension(file.path)) ?? Mime.octetStream,
        );
}

//TODO nicer debug message
class DebugResponse extends TextResponse {
  DebugResponse(dynamic error, StackTrace stack, int statusCode)
      : super.plain(
            'The following error occurred:\n$error\n$stack\n\nThis is a debug message. '
            'Messages like this will only be displayed in DEV mode.',
            statusCode: statusCode);
}

//TODO docs
class PushStreamResponse extends ApiResponse {
  final ApiResponse response;
  final Stream<ApiResponse> pushStream;

  PushStreamResponse(this.response, this.pushStream)
      : super(response.statusCode);

  @override
  Stream<List<int>> getData() => response.getData();

  @override
  Map<String, List<String>> getHeaders() => response.getHeaders();
}
