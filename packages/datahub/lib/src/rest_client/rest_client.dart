import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:datahub/http.dart';
import 'package:datahub/api.dart';
import 'package:datahub/utils.dart';

import 'rest_response.dart';

class RestClient {
  final HttpClient _httpClient;
  HttpAuth? auth;

  bool get isHttp2 => _httpClient.isHttp2;

  RestClient(this._httpClient, {this.auth});

  /// Create a [RestClient] that automatically negotiates HTTP versions.
  static Future<RestClient> connect(
    Uri address, {
    HttpAuth? auth,
    io.SecurityContext? securityContext,
    bool Function(io.X509Certificate certificate)? onBadCertificate,
    Duration? timeout = const Duration(seconds: 30),
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
      HttpClient.http11(address, securityContext: securityContext),
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

  Future<RestResponse> get(
    String endpoint, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    bool throwOnError = true,
  }) async {
    return await request(
      HttpRequestMethod.get,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      query: query,
      throwOnError: throwOnError,
    );
  }

  Future<RestResponse> post(
    String endpoint,
    dynamic object, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    bool throwOnError = true,
  }) async {
    return await request(
      HttpRequestMethod.post,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      body: object,
      query: query,
      throwOnError: throwOnError,
    );
  }

  Future<RestResponse> put(
    String endpoint,
    dynamic object, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    bool throwOnError = true,
  }) async {
    return await request(
      HttpRequestMethod.put,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      body: object,
      query: query,
      throwOnError: throwOnError,
    );
  }

  Future<RestResponse> patch(
    String endpoint,
    dynamic object, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    bool throwOnError = true,
  }) async {
    return await request(
      HttpRequestMethod.patch,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      body: object,
      query: query,
      throwOnError: throwOnError,
    );
  }

  Future<RestResponse> delete(
    String endpoint, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    bool throwOnError = true,
  }) async {
    return await request(
      HttpRequestMethod.delete,
      RoutePattern(endpoint),
      urlParams,
      headers: headers,
      query: query,
      throwOnError: throwOnError,
    );
  }

  Future<RestResponse> request(
    HttpRequestMethod method,
    RoutePattern endpoint,
    Map<String, dynamic> urlParams, {
    Map<String, List<String>> headers = const {},
    Map<String, List<String>> query = const {},
    dynamic body,
    bool throwOnError = true,
  }) async {
    final pathPrefix = _httpClient.address.pathSegments.isNotEmpty
        ? '/' +
              _httpClient.address.pathSegments
                  .where((e) => e.isNotEmpty)
                  .join('/')
        : '';
    final uri = _httpClient.address.replace(
      path: pathPrefix + endpoint.encode(urlParams),
      queryParameters: query.isNotEmpty ? query : null,
    );

    final requestHeaders = {
      ...headers,
      if (auth != null) HttpHeaders.authorization: [auth!.authorization],
    };

    final bodyData = () {
      if (body is Stream<List<int>>) {
        requestHeaders[HttpHeaders.contentType] ??= [Mime.octetStream];
        return body;
      } else if (body is Uint8List) {
        requestHeaders[HttpHeaders.contentType] ??= [Mime.octetStream];
        return Stream.value(body);
      } else if (body is String) {
        requestHeaders[HttpHeaders.contentType] ??= [
          '${Mime.plainText};charset=UTF-8',
        ];

        return Stream.value(utf8.encode(body));
      } else if (body is HttpFormData) {
        requestHeaders[HttpHeaders.contentType] ??= [Mime.formData];
        return Stream.value(utf8.encode(body.toString()));
      } else if (body != null) {
        requestHeaders[HttpHeaders.contentType] ??= [
          '${Mime.json};charset=UTF-8',
        ];
        return Stream.value(utf8.encode(jsonEncode(body)));
      } else {
        return Stream<List<int>>.empty();
      }
    }();

    final httpResponse = await _httpClient.request(
      HttpRequest(method, uri, requestHeaders, bodyData),
    );

    final restResponse = RestResponse(httpResponse);
    if (throwOnError) {
      await restResponse.throwOnError();
    }
    return restResponse;
  }

  Future<void> close() async => await _httpClient.close();
}
