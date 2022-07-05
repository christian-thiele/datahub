import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/api/middleware/request_handler.dart';

/// Errors that happen outside of [RequestHandler]s, for example
/// 404 errors where no [RequestHandler] fits the given route, requests
/// should go through middleware configuration anyway to enable handling
/// of those cases too.
///
/// This handler will be used as internal handler for middleware
/// in case of a request error that comes from inside of DataHub.
class ErrorRequestHandler implements RequestHandler {
  final ApiRequestException error;

  ErrorRequestHandler(this.error);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async => throw error;
}
