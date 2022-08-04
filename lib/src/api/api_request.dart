import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/api.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/utils.dart';

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

  /// Returns decoded body data.
  ///
  /// Useful for receiving transfer objects.
  Future<T> getBody<T>({TransferBean<T>? bean}) async {
    try {
      final json = await getJsonBody();
      if (bean != null) {
        return bean.toObject(json);
      }

      return decodeTypedNullable<T>(json) ??
          (throw ApiRequestException.badRequest('Invalid body data.'));
    } catch (_) {
      throw ApiRequestException.badRequest('Invalid body data.');
    }
  }

  /// Returns the named query parameter.
  ///
  /// Throws [ApiRequestException.badRequest] if value does not exist or could
  /// not be parsed.
  /// If a null return value is preferred instead, simply set a nullable
  /// type for [T] and no exception will be thrown.
  ///
  /// Valid types for [T] (nullable, as well as non-nullable)
  /// are [String], [int], [double], [bool], [DateTime] or [Uint8List].
  T getParam<T>(String name) {
    final decoded = decodeTypedNullable<T>(queryParams[name]);
    if (decoded is T) {
      return decoded;
    }

    throw ApiRequestException.badRequest(
        'Missing or malformed query parameter: $name');
  }
}
