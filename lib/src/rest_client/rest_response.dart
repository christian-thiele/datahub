import 'package:boost/boost.dart';

import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

class RestResponse<TResult> {
  final HttpResponse response;

  Uri get requestUrl => response.requestUrl;

  int get statusCode => response.statusCode;
  final TResult? _data;

  bool get hasData => _data != null;

  TResult get data =>
      _data ?? (throw ApiException('Response does not contain data.'));

  RestResponse(this.response, this._data);

  void throwOnError() {
    if (statusCode >= 400) {
      throw ApiRequestException(statusCode);
    }

    if (!TypeCheck<void>().isSubtypeOf<TResult>() && _data == null) {
      throw ApiException('Response does not contain data.');
    }
  }
}
