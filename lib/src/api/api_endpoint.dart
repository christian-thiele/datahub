import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/middleware/request_handler.dart';

abstract class ApiEndpoint implements RequestHandler {
  final RoutePattern routePattern;

  ApiEndpoint(this.routePattern);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    try {
      var result;
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

      return ApiResponse.dynamic(result);
    } on ApiRequestException catch (e) {
      // catch exceptions here to allow middleware to handle result
      return TextResponse.plain(e.message, e.statusCode);
    } catch (e) {
      // catch exceptions here to allow middleware to handle result
      return TextResponse.plain('500 - Internal Server Error', 500);
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
}
