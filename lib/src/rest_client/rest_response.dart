import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/utils.dart';
import 'package:http/http.dart';

class RestResponse<TResult> {
  final Uri? requestUrl;
  final int statusCode;
  final TResult? _data;

  bool get hasData => _data != null;

  TResult get data =>
      _data ?? (throw ApiException('Response does not contain data.'));

  RestResponse(Response response, this._data)
      : requestUrl = response.request?.url,
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
