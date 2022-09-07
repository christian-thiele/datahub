import 'package:boost/boost.dart';

import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

class RestResponse<TResult> {
  final Uri requestUrl;
  final int statusCode;
  final TResult? _data;

  bool get hasData => _data != null;

  TResult get data =>
      _data ?? (throw ApiException('Response does not contain data.'));

  RestResponse(HttpResponse response, this._data)
      : requestUrl = response.requestUrl,
        statusCode = response.statusCode;

  void throwOnError() {
    if (statusCode >= 400) {
      throw ApiRequestException(statusCode);
    }

    if (!TypeCheck<void>().isSubtypeOf<TResult>() && _data == null) {
      throw ApiException('Response does not contain data.');
    }
  }
}
