import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/utils.dart';

class ApiRequestException extends ApiException {
  final int statusCode;
  final Map<String, dynamic> data;

  ApiRequestException(this.statusCode, String? message,
      {Map<String, dynamic>? data})
      : data = {
          'statusCode': statusCode,
          'errorMessage': message,
          if (Zone.current[#apiRequestId] is String)
            'requestId': Zone.current[#apiRequestId],
          ...?data,
        },
        super('$statusCode ${message ?? getHttpStatus(statusCode)}');

  ApiRequestException.fromResponse(this.statusCode, this.data)
      : super(
          '$statusCode ${data['errorMessage']?.toString() ?? getHttpStatus(statusCode)}',
        );

  ApiRequestException.unauthorized([message]) : this(401, message);

  ApiRequestException.notFound([message]) : this(404, message);

  ApiRequestException.forbidden([message]) : this(403, message);

  ApiRequestException.badRequest([message]) : this(400, message);

  ApiRequestException.methodNotAllowed([message]) : this(405, message);

  ApiRequestException.internalError(message) : this(500, message);

  ApiResponse toResponse() => JsonResponse(data, statusCode);
}
