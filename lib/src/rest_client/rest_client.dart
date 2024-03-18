import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

import 'rest_response.dart';

class RestClient {
  final HttpClient _httpClient;
  HttpAuth? auth;

  bool get isHttp2 => _httpClient.isHttp2;

  RestClient(
    this._httpClient, {
    this.auth,
  });

  /// Create a [RestClient] that automatically negotiates HTTP versions.
  static Future<RestClient> connect(
    Uri address, {
    HttpAuth? auth,
    io.SecurityContext? securityContext,
    bool Function(io.X509Certificate certificate)? onBadCertificate,
    Duration? timeout,
  }) async {
    return RestClient(
      await HttpClient.autodetect(
        address,
        securityContext: securityContext,
        onBadCertificate: onBadCertificate,
        timeout: timeout,
      ),
      auth: auth,
    );
  }

  /// Create a [RestClient] with an underlying HTTP 1.1 client.
  static RestClient connectHttp11(
    Uri address, {
    HttpAuth? auth,
    io.SecurityContext? securityContext,
    bool Function(io.X509Certificate certificate)? onBadCertificate,
    Duration? timeout,
  }) {
    return RestClient(
      HttpClient.http11(
        address,
        securityContext: securityContext,
      ),
      auth: auth,
    );
  }

  /// Create a [RestClient] with an underlying HTTP 2 client.
  static RestClient connectHttp2(
    Uri address, {
    HttpAuth? auth,
    io.SecurityContext? securityContext,
    bool Function(io.X509Certificate certificate)? onBadCertificate,
    Duration? timeout,
  }) {
    return RestClient(
      HttpClient.http2(
        address,
        securityContext: securityContext,
        onBadCertificate: onBadCertificate,
        timeout: timeout,
      ),
      auth: auth,
    );
  }

  RestClient withAuth(HttpAuth? auth) => RestClient(_httpClient, auth: auth);

  Future<RestResponse<TResponse>> getObject<TResponse>(
    String endpoint, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    return await request<TResponse, TResponse>(
      ApiRequestMethod.GET,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      bean: bean,
      query: query,
    );
  }

  Future<RestResponse<List<TResponse>>> getList<TResponse>(
    String endpoint, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    return await request<TResponse, List<TResponse>>(
      ApiRequestMethod.GET,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      bean: bean,
      query: query,
    );
  }

  Future<RestResponse<TResponse>> postObject<TResponse>(
    String endpoint,
    dynamic object, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    return await request<TResponse, TResponse>(
      ApiRequestMethod.POST,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      bean: bean,
      body: object,
      query: query,
    );
  }

  Future<RestResponse<TResponse>> putObject<TResponse>(
    String endpoint,
    dynamic object, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    return await request<TResponse, TResponse>(
      ApiRequestMethod.PUT,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      bean: bean,
      body: object,
      query: query,
    );
  }

  Future<RestResponse<TResponse>> patchObject<TResponse>(
    String endpoint,
    dynamic object, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    return await request<TResponse, TResponse>(
      ApiRequestMethod.PATCH,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      bean: bean,
      body: object,
      query: query,
    );
  }

  @deprecated
  Future<RestResponse<TResponse>> rawRequest<TResponse>(
    ApiRequestMethod method,
    String endpoint, {
    dynamic body,
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    return await request<TResponse, TResponse>(
      method,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      bean: bean,
      body: body,
      query: query,
    );
  }

  Future<RestResponse<void>> delete(
    String endpoint, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    return await request<void, void>(
      ApiRequestMethod.DELETE,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      query: query,
    );
  }

  Future<RestResponse<TResponse>> request<TData, TResponse>(
    ApiRequestMethod method,
    RoutePattern endpoint,
    Map<String, dynamic> urlParams, {
    Map<String, List<String>> headers = const {},
    Map<String, List<String>> query = const {},
    dynamic body,
    TransferBean<TData>? bean,
  }) async {
    final uri = _httpClient.address.replace(
      path: endpoint.encode(urlParams),
      queryParameters: query.isNotEmpty ? query : null,
    );

    final requestHeaders = {
      ...headers,
      if (auth != null) HttpHeaders.authorization: [auth!.authorization],
    };

    final bodyData = () {
      if (body is Stream<List<int>>) {
        requestHeaders[HttpHeaders.contentType] = [Mime.octetStream];
        return body;
      } else if (body is Uint8List) {
        requestHeaders[HttpHeaders.contentType] = [Mime.octetStream];
        return Stream.value(body);
      } else if (body is String) {
        if (!requestHeaders.containsKey(HttpHeaders.contentType)) {
          requestHeaders[HttpHeaders.contentType] = [
            '${Mime.plainText}; charset=UTF-8'
          ];
        }
        return Stream.value(utf8.encode(body));
      } else if (body is HttpFormData) {
        requestHeaders[HttpHeaders.contentType] = [Mime.formData];
        return Stream.value(utf8.encode(body.toString()));
      } else if (body != null) {
        requestHeaders[HttpHeaders.contentType] = [
          '${Mime.json}; charset=UTF-8'
        ];
        return Stream.value(utf8.encode(jsonEncode(body)));
      } else {
        return Stream<List<int>>.empty();
      }
    }();

    final response = await _httpClient
        .request(HttpRequest(method, uri, requestHeaders, bodyData));

    return await handleResponse<TData, TResponse>(response, bean);
  }

  Future<RestResponse<TResponse>> handleResponse<TData, TResponse>(
    HttpResponse response,
    TransferBean<TData>? bean,
  ) async {
    try {
      if (response.statusCode < 400) {
        final data = await _handleData<TData, TResponse>(
          response.bodyData,
          response.charset ?? utf8,
          bean,
        );
        return RestResponse<TResponse>(response, data);
      } else {
        return RestResponse(response, null);
      }
    } on Exception catch (e) {
      throw ApiException('Could not process response data.', e);
    }
  }

  Future<TResponse?> _handleData<TData, TResponse>(
    Stream<List<int>> data,
    Encoding encoding,
    TransferBean<TData>? bean,
  ) async {
    final responseType = TypeCheck<TResponse>();
    if (TResponse != TData && (!responseType.isListOf<TData>())) {
      throw ApiError(
          'Invalid data and response type combination: ${TData.toString()}, ${TResponse.toString()}');
    }

    if (TResponse == Stream<List<int>>) {
      return data as TResponse;
    } else if (bean != null) {
      final obj = jsonDecode(await encoding.decodeStream(data));
      if (obj is Map<String, dynamic>) {
        final decodedData = bean.toObject(obj);
        if (responseType.isList) {
          return [decodedData] as TResponse;
        } else {
          return decodedData as TResponse;
        }
      } else if (obj is List) {
        if (responseType.isList) {
          return obj.map((e) => bean.toObject(e)).toList() as TResponse;
        }
      }

      throw ApiException('Invalid response.');
    } else if (TResponse == String) {
      return await encoding.decodeStream(data) as TResponse;
    } else if (TResponse == int) {
      return int.parse(await encoding.decodeStream(data)) as TResponse;
    } else if (TResponse == double) {
      return double.parse(await encoding.decodeStream(data)) as TResponse;
    } else if (TResponse == Uint8List) {
      return await data.collect() as TResponse;
    } else if (responseType.isMapOf<String, dynamic>() || responseType.isList) {
      return jsonDecode(await encoding.decodeStream(data)) as TResponse;
    } else if (TypeCheck<void>().isSubtypeOf<TResponse>()) {
      return null;
    }

    throw ApiError.invalidType(TResponse);
  }

  Future<void> close() async => await _httpClient.close();
}
