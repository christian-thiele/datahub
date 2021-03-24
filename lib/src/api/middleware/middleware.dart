import 'package:cl_datahub/src/api/api_request.dart';
import 'package:cl_datahub/src/api/api_response.dart';
import 'package:cl_datahub/src/api/middleware/request_handler.dart';

typedef MiddlewareBuilder = RequestHandler Function(RequestHandler);

abstract class Middleware extends RequestHandler {
  final RequestHandler internal;

  Middleware(this.internal);

  Future<ApiResponse> next(ApiRequest request) async {
    return await internal.handleRequest(request);
  }
}
