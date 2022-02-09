import 'dart:convert';
import 'dart:typed_data';

import 'package:cl_datahub/api.dart';

import 'request_context.dart';

class ApiRequest {
  final RequestContext context;
  final ApiRequestMethod method;
  final Route route;
  final Map<String, List<String>> headers;
  final Map<String, String> queryParams;
  final Stream<List<int>> bodyData;

  ApiRequest(this.context, this.method, this.route, this.headers,
      this.queryParams, this.bodyData);

  /// Returns a Uint8List of the body data.
  ///
  /// Useful for small size bodies. For large amounts of data use
  /// [bodyData] stream instead.
  Future<Uint8List> getByteBody() async =>
      Uint8List.fromList(await bodyData.expand((element) => element).toList());

  /// Returns a String representation of the body data.
  ///
  /// Useful for small size bodies. For large amounts of data use
  /// [bodyData] stream instead.
  Future<String> getTextBody() async => utf8.decode(await getByteBody());

  /// Returns a Map<String, dynamic> representation of json body data.
  ///
  /// Useful for small size bodies. For large amounts of data use
  /// [bodyData] stream instead.
  Future<Map<String, dynamic>> getJsonBody() async {
    try {
      return JsonDecoder().convert(await getTextBody()) as Map<String, dynamic>;
    } catch (_) {
      throw ApiRequestException.badRequest('Invalid body data.');
    }
  }

  /// Returns the named query parameter.
  ///
  /// Throws [ApiRequestException.badRequest] if value does not exist and
  /// [fallback] is null.
  String getParam(String name, [String? fallback]) {
    return queryParams[name]?.toString() ??
        fallback ??
        (throw ApiRequestException.badRequest('Missing query param: $name'));
  }

  /// Returns the named query parameter of the request as int.
  ///
  /// Throws [ApiRequestException.badRequest] if value does not exist and
  /// [fallback] is null or if value is not an integer.
  int getParamInt(String name, [int? fallback]) {
    if (queryParams[name] != null) {
      return int.tryParse(queryParams[name]!) ??
          (throw ApiRequestException.badRequest('Invalid query param: $name'));
    }

    return fallback ??
        (throw ApiRequestException.badRequest('Missing query param: $name'));
  }
}
