import 'dart:convert';
import 'dart:typed_data';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/cl_datahub.dart';

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
  ///
  /// Valid types for [T] are [String], [int], [double], [bool], [DateTime] or [Uint8List].
  T getParam<T>(String name, [T? fallback]) {
    return decodeTypedNullable<T>(queryParams[name]) ??
        fallback ??
        (throw ApiRequestException.badRequest('Missing query param: $name'));
  }
}
