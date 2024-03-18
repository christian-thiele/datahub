import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

class ApiRequest {
  final ApiRequestMethod method;
  final Route route;
  final Map<String, List<String>> headers;
  final Map<String, List<String>> queryParams;
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

  /// Returns a [Uint8List] of the body data.
  ///
  /// Useful for small size bodies. For large amounts of data use
  /// [bodyData] stream instead.
  Future<Uint8List> getByteBody() async =>
      Uint8List.fromList(await bodyData.expand((element) => element).toList());

  /// Returns a [String] representation of the body data.
  ///
  /// Useful for small size bodies. For large amounts of data use
  /// [bodyData] stream instead.
  Future<String> getTextBody() async => utf8.decode(await getByteBody());

  /// Returns a [Map<String, dynamic>] representation of json body data.
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

  /// Returns a [List] representation of json body data.
  ///
  /// Useful for small size bodies. For large amounts of data use
  /// [bodyData] stream instead.
  Future<List> getJsonListBody() async {
    try {
      return JsonDecoder().convert(await getTextBody()) as List;
    } catch (_) {
      throw ApiRequestException.badRequest('Invalid body data.');
    }
  }

  /// Returns decoded body data.
  ///
  /// Useful for receiving transfer objects.
  /// Allowed types are: [String], [Map<String, dynamic>], [List<dynamic>],
  /// [Uint8List], [Stream<Uint8List>], [dynamic].
  ///
  /// If T is dynamic, the body data will be returned as json (Map or List).
  Future<T> getBody<T>({TransferBean<T>? bean}) async {
    try {
      if (bean != null) {
        return bean.toObject(await getJsonBody());
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
      }
    } on CodecException catch (e) {
      throw ApiRequestException.badRequest(e.message);
    } catch (_) {
      throw ApiRequestException.badRequest('Invalid body data.');
    }

    throw ApiError.invalidType(T);
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
      if (TypeCheck<T>().isSubtypeOf<List?>()) {
        return decodeTyped<T>(queryParams[name]);
      } else {
        return decodeTyped<T>(queryParams[name]?.lastOrNull);
      }
    } on CodecException catch (_) {
      throw ApiRequestException.badRequest(
          'Missing or malformed query parameter: $name');
    }
  }

  /// Returns the current session of type [T].
  ///
  /// Use [AuthProvider] to populate the request session object.
  ///
  /// If there is no active session matching type [T], this will throw an
  /// [ApiRequestException.unauthorized]. If in this case a null return value
  /// is preferred instead, simply set a nullable type for [T] and no exception
  /// will be thrown.
  T getSession<T extends Session>() {
    if (session is T) {
      return session as T;
    } else {
      throw ApiRequestException.unauthorized();
    }
  }

  ApiRequest withSession(Session? session) =>
      ApiRequest(method, route, headers, queryParams, bodyData, session);
}
