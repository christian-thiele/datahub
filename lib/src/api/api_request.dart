import 'dart:convert';
import 'dart:typed_data';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/request_context.dart';
import 'file:///home/christian/IdeaProjects/corelight_datahub/datahub_common/lib/src/utils/api_error.dart';

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

  dynamic getJsonBody() => JsonDecoder().convert(getTextBody());

  //TODO doc -> throw behaviour etc
  String getParam(String name, [String? fallback]) {
    return queryParams[name]?.toString() ??
        fallback ??
        (throw ApiRequestException.badRequest('Missing route param: $name'));
  }

  //TODO doc -> throw behaviour etc
  int getParamInt(String name, [int? fallback]) {
    if (queryParams[name] != null) {
      return int.tryParse(queryParams[name]!) ??
          (throw ApiRequestException.badRequest('Invalid route param: $name'));
    }

    return fallback ??
        (throw ApiRequestException.badRequest('Missing route param: $name'));
  }
}
