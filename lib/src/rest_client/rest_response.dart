import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';

import 'package:datahub/datahub.dart';

class RestResponse implements HttpResponse {
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
  Stream<List<int>> get bodyData => _httpResponse.bodyData;

  @override
  Encoding get charset => _httpResponse.charset ?? utf8;

  RestResponse(this._httpResponse);

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
  Future<T> getBody<T>({TransferBean? bean}) async {
    if (bean != null) {
      final obj = jsonDecode(await charset.decodeStream(bodyData));

      if (bean.codec.isSubtypeOf<T>() || T == dynamic) {
        if (obj is List) {
          throw ApiException('Expected $T but received List.');
        } else {
          return bean.toObject(obj) as T;
        }
      } else if (bean.codec.toList.isSubtypeOf<T>()) {
        if (obj is List) {
          return obj.map((e) => bean.toObject(e)).cast<T>().toList() as T;
        } else {
          throw ApiException('Expected $T but received Object.');
        }
      } else {
        throw ApiError(
            'TransferBean<${bean.codec.name}> does not match response type $T');
      }
    } else if (T == String) {
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
      if (headers['content-type']?.contains(Mime.json) ?? false) {
        try {
          final textBody = await getTextBody();
          try {
            final jsonBody = jsonDecode(textBody) as Map<String, dynamic>;
            throw ApiRequestException.fromResponse(
              statusCode,
              {
                'statusCode': statusCode,
                ...jsonBody,
              },
            );
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
          throw ApiRequestException.fromResponse(
            statusCode,
            {
              'statusCode': statusCode,
              'clientError': 'Could not parse error response.',
              'clientErrorDetails': e.toString(),
            },
          );
        }
      } else if (headers['content-type']?.contains(Mime.plainText) ?? false) {
        // Create exception data that are similar to datahub error responses for
        // servers that are not providing json error data.
        try {
          throw ApiRequestException.fromResponse(
            statusCode,
            {
              'statusCode': statusCode,
              'errorMessage': await getTextBody(),
            },
          );
        } on ApiRequestException catch (_) {
          rethrow;
        } catch (e) {
          throw ApiRequestException.fromResponse(
            statusCode,
            {
              'statusCode': statusCode,
              'clientError': 'Could not parse error response.',
              'clientErrorDetails': e.toString(),
            },
          );
        }
      }

      throw ApiRequestException.fromResponse(statusCode, {});
    }
  }
}

extension RestResponseFutureExtension on Future<RestResponse> {
  /// Convenience method for accessing response data.
  ///
  /// Example:
  /// `dart
  ///   final data = await restClient.getObject<Dto>('...', bean: DtoTransferBean).thenGetBody();
  /// `
  ///
  /// instead of
  ///
  /// `dart
  ///   final response = await restClient.getObject<Dto>('...', bean: DtoTransferBean);
  ///   final data = await response.getBody();
  /// `
  Future<TResponse> thenGetBody<TResponse>({TransferBean? bean}) =>
      then((response) => response.getBody<TResponse>(bean: bean));

  /// Convenience method for accessing response data.
  ///
  /// Example:
  /// `dart
  ///   final data = await restClient.getObject<Dto>('...', bean: DtoTransferBean).thenGetByteBody();
  /// `
  ///
  /// instead of
  ///
  /// `dart
  ///   final response = await restClient.getObject<Dto>('...', bean: DtoTransferBean);
  ///   final data = await response.getByteBody();
  /// `
  Future<Uint8List> thenGetByteBody<TResponse>() =>
      then((response) => response.getByteBody());

  /// Convenience method for accessing response data.
  ///
  /// Example:
  /// `dart
  ///   final data = await restClient.getObject<Dto>('...', bean: DtoTransferBean).thenGetJsonBody();
  /// `
  ///
  /// instead of
  ///
  /// `dart
  ///   final response = await restClient.getObject<Dto>('...', bean: DtoTransferBean);
  ///   final data = await response.getJsonBody();
  /// `
  Future<Map<String, dynamic>> thenGetJsonBody() =>
      then((response) => response.getJsonBody());

  /// Convenience method for accessing response data.
  ///
  /// Example:
  /// `dart
  ///   final data = await restClient.getObject<Dto>('...', bean: DtoTransferBean).thenGetJsonListBody();
  /// `
  ///
  /// instead of
  ///
  /// `dart
  ///   final response = await restClient.getObject<Dto>('...', bean: DtoTransferBean);
  ///   final data = await response.getJsonListBody();
  /// `
  Future<List<dynamic>> thenGetJsonListBody() =>
      then((response) => response.getJsonListBody());

  /// Convenience method for accessing response data.
  ///
  /// Example:
  /// `dart
  ///   final data = await restClient.getObject<Dto>('...', bean: DtoTransferBean).thenGetTextBody();
  /// `
  ///
  /// instead of
  ///
  /// `dart
  ///   final response = await restClient.getObject<Dto>('...', bean: DtoTransferBean);
  ///   final data = await response.getTextBody();
  /// `
  Future<String> thenGetTextBody() =>
      then((response) => response.getTextBody());

  /// Convenience method for accessing response data.
  ///
  /// Example:
  /// `dart
  ///   final data = await restClient.getObject<Dto>('...', bean: DtoTransferBean).thenGetBodyData();
  /// `
  ///
  /// instead of
  ///
  /// `dart
  ///   final response = await restClient.getObject<Dto>('...', bean: DtoTransferBean);
  ///   final data = await response.bodyData;
  /// `
  Future<Stream<List<int>>> thenGetBodyData() =>
      then((response) => response.bodyData);
}
