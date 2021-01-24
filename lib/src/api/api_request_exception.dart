import 'package:cl_datahub/api.dart';

class ApiRequestException extends ApiException {
  final int statusCode;

  ApiRequestException(this.statusCode, String message) : super(message);

  ApiRequestException.unauthorized(message) : this(401, message);
  ApiRequestException.notFound(message) : this(404, message);
  ApiRequestException.forbidden(message) : this(403, message);

  ApiRequestException.internalError(message) : this(500, message);
}