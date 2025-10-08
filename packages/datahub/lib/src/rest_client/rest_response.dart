import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/data.dart';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

class RestResponse implements HttpResponse {
  static final Finalizer<HttpResponse> _finalizer = Finalizer(
    (response) => response.bodyData.drain(),
  );

  final HttpResponse _httpResponse;

  @override
  Map<String, List<String>> get headers => _httpResponse.headers;

  @override
  Uri get requestUrl => _httpResponse.requestUrl;

  @override
  int get statusCode => _httpResponse.statusCode;

  /// Returns the raw body data.
  ///
  /// Since body data is streamed, it can only be received once.
  /// A call to one of the following methods / getters will drain the body stream:
  ///   - [bodyData]
  ///   - [getBody]
  ///   - [getTextBody]
  ///   - [getJsonBody]
  ///
  /// Also [throwOnError] will drain the stream to parse error data in the case
  /// of a non-success status code.
  @override
  Stream<List<int>> get bodyData => _httpResponse.bodyData.transform(
    StreamListenHook(() => _finalizer.detach(this)),
  );

  @override
  Encoding get charset => _httpResponse.charset ?? utf8;

  RestResponse(this._httpResponse) {
    _finalizer.attach(this, _httpResponse, detach: this);
  }

  /// Returns the response body as [TResult].
  ///
  /// If the response body data cannot be converted to [TResult], this
  /// will throw an [ApiException].
  ///
  /// Since body data is streamed, it can only be received once.
  /// A call to one of the following methods / getters will drain the body stream:
  ///   - [bodyData]
  ///   - [getBody]
  ///   - [getTextBody]
  ///   - [getJsonBody]
  ///
  /// Also [throwOnError] will drain the stream to parse error data in the case
  /// of a non-success status code.
  Future<T> getBody<T>() async {
    if (T == String) {
      return await getTextBody() as T;
    } else if (T == Map<String, dynamic>) {
      return await getJsonBody() as T;
    } else if (T == Uint8List) {
      return await getByteBody() as T;
    } else if (T == List<dynamic>) {
      return await getJsonListBody() as T;
    } else if (T == Stream<Uint8List>) {
      return bodyData.asUint8List() as T;
    } else if (T == Stream<List<int>>) {
      return bodyData as T;
    } else if (T == dynamic) {
      return jsonDecode(await getTextBody());
    } else if (TypeCheck<void>().isSubtypeOf<T>()) {
      return null as T;
    }

    throw ApiError.invalidType(T);
  }

  Future<T> getData<T extends DataObject<T>>(DataBean<T> bean) async {
    final json = await getJsonBody();
    return bean.fromJson(json);
  }

  Future<List<T>> getList<T extends DataObject<T>>(DataBean<T> bean) async {
    final obj = jsonDecode(await charset.decodeStream(bodyData));
    final codec = const JsonDataCodec();
    return codec.decodeList(obj, bean.fromJson);
  }

  /// Returns the response body as [Uint8List].
  ///
  /// If the response body data cannot be converted to string, this
  /// will throw an [ApiException].
  ///
  /// Since body data is streamed, it can only be received once.
  /// A call to one of the following methods / getters will drain the body stream:
  ///   - [bodyData]
  ///   - [getBody]
  ///   - [getByteBody]
  ///   - [getTextBody]
  ///   - [getJsonBody]
  ///
  /// Also [throwOnError] will drain the stream to parse error data in the case
  /// of a non-success status code.
  Future<Uint8List> getByteBody() async => await bodyData.collect();

  /// Returns the response body as string.
  ///
  /// If the response body data cannot be converted to string, this
  /// will throw an [ApiException].
  ///
  /// Since body data is streamed, it can only be received once.
  /// A call to one of the following methods / getters will drain the body stream:
  ///   - [bodyData]
  ///   - [getBody]
  ///   - [getByteBody]
  ///   - [getTextBody]
  ///   - [getJsonBody]
  ///
  /// Also [throwOnError] will drain the stream to parse error data in the case
  /// of a non-success status code.
  Future<String> getTextBody() async {
    try {
      return await charset.decodeStream(bodyData);
    } catch (e) {
      throw ApiException('Cannot convert body data to string.', e);
    }
  }

  /// Returns the response body as json map.
  ///
  /// If the response body data cannot be converted to string, this
  /// will throw an [ApiException].
  ///
  /// Since body data is streamed, it can only be received once.
  /// A call to one of the following methods / getters will drain the body stream:
  ///   - [bodyData]
  ///   - [getBody]
  ///   - [getByteBody]
  ///   - [getTextBody]
  ///   - [getJsonBody]
  ///
  /// Also [throwOnError] will drain the stream to parse error data in the case
  /// of a non-success status code.
  Future<Map<String, dynamic>> getJsonBody() async {
    try {
      return await charset.decodeStream(bodyData).then(jsonDecode)
          as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Cannot convert body data to json map.', e);
    }
  }

  /// Returns the response body as json list.
  ///
  /// If the response body data cannot be converted to string, this
  /// will throw an [ApiException].
  ///
  /// Since body data is streamed, it can only be received once.
  /// A call to one of the following methods / getters will drain the body stream:
  ///   - [bodyData]
  ///   - [getBody]
  ///   - [getByteBody]
  ///   - [getTextBody]
  ///   - [getJsonBody]
  ///
  /// Also [throwOnError] will drain the stream to parse error data in the case
  /// of a non-success status code.
  Future<List<dynamic>> getJsonListBody() async {
    try {
      return await charset.decodeStream(bodyData).then(jsonDecode)
          as List<dynamic>;
    } catch (e) {
      throw ApiException('Cannot convert body data to json map.', e);
    }
  }

  /// Throws an [ApiRequestException] if the status code is greater or equal to 400.
  ///
  /// If this method throws, [bodyData] can not be accessed anymore because
  /// the stream is drained to parse exception data.
  /// Body data can be accessed via the [ApiRequestException] that is thrown.
  ///
  /// This method is called by [RestClient] by default before returning
  /// the response. This can be disabled by setting the `throwOnError`
  /// argument on request methods to false.
  ///
  /// Also [throwOnError] will drain the stream to parse error data in the case
  /// of a non-success status code.
  Future<void> throwOnError() async {
    if (statusCode >= 400) {
      if (Mime.fromContentType(headers['content-type']?.firstOrNull) ==
          Mime.json) {
        try {
          final textBody = await getTextBody();
          try {
            final jsonBody = jsonDecode(textBody) as Map<String, dynamic>;
            throw ApiRequestException.fromResponse(statusCode, {
              'statusCode': statusCode,
              ...jsonBody,
            });
          } on ApiRequestException catch (_) {
            rethrow;
          } catch (_) {
            throw ApiRequestException.fromResponse(statusCode, {
              'statusCode': statusCode,
              'errorBody': textBody,
            });
          }
        } on ApiRequestException catch (_) {
          rethrow;
        } catch (e) {
          throw ApiRequestException.fromResponse(statusCode, {
            'statusCode': statusCode,
            'clientError': 'Could not parse error response.',
            'clientErrorDetails': e.toString(),
          });
        }
      } else if (Mime.fromContentType(headers['content-type']?.firstOrNull) ==
          Mime.plainText) {
        // Create exception data that are similar to datahub error responses for
        // servers that are not providing json error data.
        try {
          throw ApiRequestException.fromResponse(statusCode, {
            'statusCode': statusCode,
            'errorMessage': await getTextBody(),
          });
        } on ApiRequestException catch (_) {
          rethrow;
        } catch (e) {
          throw ApiRequestException.fromResponse(statusCode, {
            'statusCode': statusCode,
            'clientError': 'Could not parse error response.',
            'clientErrorDetails': e.toString(),
          });
        }
      }

      throw ApiRequestException.fromResponse(statusCode, {});
    }
  }

  /// Discards the body stream.
  ///
  /// The [RestResponse] expects the user-code to consume and handle the body
  /// data of a request in some way by calling any of the get...Body() methods
  /// or accessing the [bodyData] Stream directly.
  ///
  /// If it is certain, that the body data will not be accessed, then call
  /// [discard] to avoid memory leaks.
  Future<void> discard() async {
    try {
      await bodyData.drain();
    } catch (e) {
      print(e);
    }
  }
}

extension RestResponseFutureExtension on Future<RestResponse> {
  Future<TResponse> thenGetBody<TResponse>() =>
      then((response) => response.getBody<TResponse>());

  Future<TResponse> thenGetData<TResponse extends DataObject<TResponse>>(
    DataBean<TResponse> bean,
  ) => then((response) => response.getData<TResponse>(bean));

  Future<List<TResponse>> thenGetList<TResponse extends DataObject<TResponse>>(
    DataBean<TResponse> bean,
  ) => then((response) => response.getList<TResponse>(bean));

  Future<Uint8List> thenGetByteBody<TResponse>() =>
      then((response) => response.getByteBody());

  Future<Map<String, dynamic>> thenGetJsonBody() =>
      then((response) => response.getJsonBody());

  Future<List<dynamic>> thenGetJsonListBody() =>
      then((response) => response.getJsonListBody());

  Future<String> thenGetTextBody() =>
      then((response) => response.getTextBody());

  Future<Stream<List<int>>> thenGetBodyData() =>
      then((response) => response.bodyData);
}
