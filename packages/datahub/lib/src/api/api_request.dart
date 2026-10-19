import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

class ApiRequest(
  final Uri uri,
  final HttpRequestMethod method,
  final Map<String, List<String>> headers,
  final Map<String, String> routeParams,
  final Stream<List<int>> bodyData,
) {
  Map<String, List<String>> get queryParams => uri.queryParametersAll;

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
      return const JsonDecoder().convert(await getTextBody())
          as Map<String, dynamic>;
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
      return const JsonDecoder().convert(await getTextBody()) as List;
    } catch (_) {
      throw ApiRequestException.badRequest('Invalid body data.');
    }
  }

  /// Returns decoded body data.
  ///
  /// Allowed types are: [String], [Map<String, dynamic>], [List<dynamic>],
  /// [Uint8List], [Stream<Uint8List>], [dynamic].
  ///
  /// If T is dynamic, the body data will be returned as json (Map or List).
  Future<dynamic> getBody<T>() async {
    try {
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
      } else if (const TypeCheck<void>().isSubtypeOf<T>()) {
        return null as T;
      }
    } on CodecException catch (e) {
      throw ApiRequestException.badRequest(e.message);
    } on ApiRequestException {
      rethrow;
    } catch (_) {
      throw ApiRequestException.badRequest('Invalid body data.');
    }

    throw ApiError.invalidType(T);
  }

  /// Returns decoded body data using a [DataBean].
  ///
  /// Throws [ApiRequestException.badRequest] if the body could not be decoded.
  Future<T> getData<T extends DataObject>(DataBean<T> bean) async {
    final json = await getJsonBody();
    try {
      return bean.fromJson(json);
    } on CodecException catch (e) {
      throw ApiRequestException.badRequest(e.message);
    }
  }

  /// Returns decoded body data as list using a [DataBean].
  ///
  /// Setting [allowSingleFlat] to true enables parsing of a json object
  /// (instead of a list of objects) into a list with one item instead of
  /// throwing a bad-request exception.
  ///
  /// Throws [ApiRequestException.badRequest] if the body could not be decoded.
  Future<List<T>> getList<T extends DataObject>(
    DataBean<T> bean, {
    bool allowSingleFlat = false,
  }) async {
    try {
      final json = jsonDecode(await getTextBody());

      return switch (json) {
        Map<String, dynamic>() when allowSingleFlat => [bean.fromJson(json)],
        List<dynamic>() =>
          json.indexed
              .map((e) => bean.fromJson(e.$2, name: '[${e.$1}]'))
              .toList(),
        _ => throw ApiRequestException.badRequest('Invalid body data.'),
      };
    } on CodecException catch (e) {
      throw ApiRequestException.badRequest(e.message);
    } on FormatException catch (_) {
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
      final codec = const JsonDataCodec();
      if (TypeCheck<T>().isSubtypeOf<List?>()) {
        return codec.decodeTyped<T>(queryParams[name]);
      } else {
        return codec.decodeTyped<T>(queryParams[name]?.lastOrNull);
      }
    } on CodecException catch (_) {
      throw ApiRequestException.badRequest(
        'Missing or malformed query parameter: $name',
      );
    }
  }

  /// Returns the named route parameter.
  ///
  /// Throws [ApiRequestException.badRequest] if value does not exist or could
  /// not be parsed.
  /// If a null return value is preferred instead, simply set a nullable
  /// type for [T] and no exception will be thrown.
  ///
  /// Valid types for [T] (nullable, as well as non-nullable)
  /// are [String], [int], [double], [bool], [DateTime], [Duration] or [Uint8List].
  T getRouteParam<T>(String name) {
    try {
      final codec = const JsonDataCodec();
      return codec.decodeTyped<T>(routeParams[name]);
    } on CodecException catch (_) {
      throw ApiRequestException.badRequest(
        'Missing or malformed route parameter: $name',
      );
    }
  }
}
