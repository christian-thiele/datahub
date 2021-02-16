import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/utils.dart';

class ApiRequestException extends ApiException {
  final int statusCode;

  ApiRequestException(this.statusCode, [String? message])
      : super(_toMessage(statusCode, message));

  ApiRequestException.unauthorized([message]) : this(401, message);
  ApiRequestException.notFound([message]) : this(404, message);
  ApiRequestException.forbidden([message]) : this(403, message);
  ApiRequestException.badRequest([message]) : this(400, message);
  ApiRequestException.methodNotAllowed([message]) : this(405, message);

  ApiRequestException.internalError(message) : this(500, message);

  static String _toMessage(int statusCode, String? message) {
    if (nullOrEmpty(message)) {
      return getHttpStatus(statusCode);
    }

    return message!;
  }
}
