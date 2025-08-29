import 'package:datahub/api.dart';

abstract class RequestHandler {
  Future<ApiResponse> handleRequest(ApiRequest request);
}
