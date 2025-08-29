import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';

import 'middleware/request_handler.dart';

/// A RequestHandler with a [RoutePattern] to match against.
///
/// ApiEndpoint provides basic error response conversion.
/// To use it, override any of the [get], [post], [put], [patch], [delete]
/// methods. It is safe to throw exceptions inside of them.
///
/// A [ApiRequestException] thrown from inside of the handler methods
/// will result in the corresponding ApiResponse.
///
/// Any other Exception thrown will be converted to a response with status code
/// 500. If DataHub runs in [Environment.dev] configuration, the exception
/// and its stack trace will be included as text in the response.
/// (See [DebugResponse].)
abstract class ApiEndpoint extends RequestHandler {
  final RoutePattern routePattern;

  ApiEndpoint(this.routePattern);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    try {
      final result = switch (request.method) {
        ApiRequestMethod.GET => await get(request),
        ApiRequestMethod.POST => await post(request),
        ApiRequestMethod.PUT => await put(request),
        ApiRequestMethod.PATCH => await patch(request),
        ApiRequestMethod.DELETE => await delete(request),
        ApiRequestMethod.OPTIONS => await options(request),
        ApiRequestMethod.HEAD => await head(request),
        ApiRequestMethod.TRACE => await trace(request),
      };
      return ApiResponse.dynamic(result);
    } catch (e, stack) {
      return errorResponse(request, e, stack);
    }
  }

  Future<dynamic> get(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> post(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> put(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> patch(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> delete(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> head(ApiRequest request) async {
    try {
      return HeadResponse(ApiResponse.dynamic(await get(request)));
    } catch (e, stack) {
      return HeadResponse(errorResponse(request, e, stack));
    }
  }

  Future<dynamic> options(ApiRequest request) async =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> trace(ApiRequest request) async =>
      throw ApiRequestException.methodNotAllowed();

  /// Wraps the execution of a request handler to ensure that an [ApiResponse]
  /// is the result.
  ///
  /// If the handler throws anything *but* an [ApiRequestException],
  /// the exception will be transformed into an ApiResponse with status code 500.
  /// If the application environment is set to [Environment.dev],
  /// said response will be a [DebugResponse].
  ApiResponse errorResponse(
      ApiRequest request, dynamic error, StackTrace stackTrace) {
    if (error is ApiRequestException) {
      return error.toResponse();
    }

    resolve<LogService>().error(
      'Error while handling request to "${request.route}".',
      error: error,
      trace: stackTrace,
      sender: 'DataHub',
    );
    if (resolve<ConfigService>().environment == Environment.dev) {
      return DebugResponse(error, stackTrace, 500);
    } else {
      return ApiRequestException.internalError('Internal Server Error')
          .toResponse();
    }
  }
}
