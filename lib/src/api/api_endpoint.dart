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
      var result = await before(request);
      if (result == null) {
        switch (request.method) {
          case ApiRequestMethod.GET:
            result = await get(request);
            break;
          case ApiRequestMethod.POST:
            result = await post(request);
            break;
          case ApiRequestMethod.PUT:
            result = await put(request);
            break;
          case ApiRequestMethod.PATCH:
            result = await patch(request);
            break;
          case ApiRequestMethod.DELETE:
            result = await delete(request);
            break;
        }
      }

      return ApiResponse.dynamic(result);
    } on ApiRequestException catch (e) {
      // catch exceptions here to allow middleware to handle result
      return e.toResponse();
    } catch (e, stack) {
      resolve<LogService>().error(
        'Error while handling request to "${request.route}".',
        error: e,
        trace: stack,
        sender: 'DataHub',
      );

      // catch exceptions here to allow middleware to handle result
      if (resolve<ConfigService>().environment == Environment.dev) {
        return DebugResponse(e, stack, 500);
      } else {
        return ApiRequestException.internalError('Internal Server Error')
            .toResponse();
      }
    }
  }

  /// This method gets called before every call to get, post, put, patch or delete.
  /// If this method throws an exception or returns anything other than null,
  /// the result is treated as response and the subsequent call to get, post, etc.
  /// will be skipped. (Useful for checking authorization.)
  Future<dynamic> before(ApiRequest request) async => null;

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
}
