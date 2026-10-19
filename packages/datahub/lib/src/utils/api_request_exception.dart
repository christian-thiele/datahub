import 'dart:async';

import 'package:datahub/utils.dart';

import '../api/api_response.dart';

/// An exception that can explicitly be transformed into an [ApiResponse]
/// using [toResponse].
class ApiRequestException extends ApiException {
  final int statusCode;
  final Map<String, dynamic> data;

  new(this.statusCode, String? message, {Map<String, dynamic>? data})
    : data = {
        'statusCode': statusCode,
        'errorMessage': message,
        if (Zone.current[#apiRequestId] is String)
          'requestId': Zone.current[#apiRequestId],
        ...?data,
      },
      super('$statusCode ${message ?? getHttpStatus(statusCode)}');

  new fromResponse(this.statusCode, this.data)
    : super(
        '[$statusCode] ${data['errorMessage']?.toString() ?? getHttpStatus(statusCode)}',
      );

  new unauthorized([String? message]) : this(401, message);

  new notFound([String? message]) : this(404, message);

  new forbidden([String? message]) : this(403, message);

  new badRequest([String? message]) : this(400, message);

  new methodNotAllowed([String? message]) : this(405, message);

  new internalError([String? message]) : this(500, message);

  new serviceUnavailable([String? message]) : this(503, message);

  ApiResponse toResponse() => ApiRequestExceptionResponse(this);
}

class ApiRequestExceptionResponse(final ApiRequestException exception)
    extends JsonResponse {
  this : super(exception.data, statusCode: exception.statusCode);
}
