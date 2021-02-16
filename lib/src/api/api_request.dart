import 'dart:convert';
import 'dart:typed_data';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/api_error.dart';

class ApiRequest {
  // TODO bundle route, params into class
  final ApiRequestMethod method;
  final Route route;
  final Map<String, dynamic> queryParams;
  final Uint8List? _bodyData;

  bool get hasBodyData => _bodyData != null;

  Uint8List get bodyData =>
      _bodyData ?? (throw ApiError('Request does not contain body data.'));

  ApiRequest(this.method, this.route, this.queryParams, this._bodyData);

  String getTextBody() => utf8.decode(bodyData);

  dynamic getJsonBody() => JsonDecoder().convert(getTextBody());
}
