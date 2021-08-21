import 'package:cl_datahub/src/api/api_request.dart';
import 'package:cl_datahub/src/api/api_response.dart';
import 'package:cl_datahub/src/api/middleware/middleware.dart';
import 'package:cl_datahub/src/api/middleware/request_handler.dart';

class LogMiddleware extends Middleware {
  LogMiddleware(RequestHandler internal) : super(internal);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    // Pre-Handler
    print('${request.method}: ${request.route}'); //TODO logging

    final result = await next(request);

    // Post-Handler
    print('Result: ${result.statusCode}'); //TODO logging

    return result;
  }
}
