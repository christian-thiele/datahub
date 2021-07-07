import 'dart:convert';
import 'dart:typed_data';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/request_context.dart';
import 'package:cl_datahub_common/common.dart';

class ApiRequest {
  final RequestContext context;
  final ApiRequestMethod method;
  final Route route;
  final Map<String, List<String>> headers;
  final Map<String, String> queryParams;
  final Uint8List? _bodyData;

  bool get hasBodyData => _bodyData != null;

  Uint8List get bodyData =>
      _bodyData ?? (throw ApiError('Request does not contain body data.'));

  ApiRequest(this.context, this.method, this.route, this.headers,
      this.queryParams, this._bodyData);

  String getTextBody() => utf8.decode(bodyData);

  Map<String, dynamic> getJsonBody() {
    try {
      return JsonDecoder().convert(getTextBody()) as Map<String, dynamic>;
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
