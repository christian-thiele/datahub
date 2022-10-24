import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

class ApiRequest {
  final ApiRequestMethod method;
  final Route route;
  final Map<String, List<String>> headers;
  final Map<String, String> queryParams;
  final Stream<List<int>> bodyData;
  final Session? session;

  ApiRequest(
    this.method,
    this.route,
    this.headers,
    this.queryParams,
    this.bodyData,
    this.session,
  );

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

      return decodeTyped<T>(json);
    } on CodecException catch (e) {
      throw ApiRequestException.badRequest(e.message);
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
  /// are [String], [int], [double], [bool], [DateTime], [Duration] or [Uint8List].
  T getParam<T>(String name) {
    try {
      return decodeTyped<T>(queryParams[name]);
    } on CodecException catch (_) {
      throw ApiRequestException.badRequest(
          'Missing or malformed query parameter: $name');
    }
  }

  ApiRequest withSession(Session? session) =>
      ApiRequest(method, route, headers, queryParams, bodyData, session);
}
