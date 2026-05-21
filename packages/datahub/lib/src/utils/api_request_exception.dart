import 'dart:async';

import 'package:datahub/utils.dart';

import '../api/api_response.dart';

/// An exception that can explicitly be transformed into an [ApiResponse]
/// using [toResponse].
class ApiRequestException extends ApiException {
  final int statusCode;
  final Map<String, dynamic> data;

  ApiRequestException(
    this.statusCode,
    String? message, {
    Map<String, dynamic>? data,
  }) : data = {
         'statusCode': statusCode,
         'errorMessage': message,
         if (Zone.current[#apiRequestId] is String)
           'requestId': Zone.current[#apiRequestId],
         ...?data,
       },
       super('$statusCode ${message ?? getHttpStatus(statusCode)}');

  ApiRequestException.fromResponse(this.statusCode, this.data)
    : super(
        '[$statusCode] ${data['errorMessage']?.toString() ?? getHttpStatus(statusCode)}',
      );

  ApiRequestException.unauthorized([String? message]) : this(401, message);

  ApiRequestException.notFound([String? message]) : this(404, message);

  ApiRequestException.forbidden([String? message]) : this(403, message);

  ApiRequestException.badRequest([String? message]) : this(400, message);

  ApiRequestException.methodNotAllowed([String? message]) : this(405, message);

  ApiRequestException.internalError([String? message]) : this(500, message);

  ApiResponse toResponse() => ApiRequestExceptionResponse(this);
}

class ApiRequestExceptionResponse extends JsonResponse {
  final ApiRequestException exception;

  ApiRequestExceptionResponse(this.exception)
    : super(exception.data, statusCode: exception.statusCode);
}
