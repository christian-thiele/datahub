import 'dart:async';

import 'package:datahub/http.dart';

import 'api_request.dart';
import 'api_response.dart';
import 'route_matcher.dart';

typedef RequestHandler<T> = FutureOr<T> Function(ApiRequest request);
typedef MiddlewareRequestHandler<T> = FutureOr<T> Function(
  ApiRequest request,
  RequestHandler<ApiResponse> handler,
);

/// Building-block for defining the structure of APIs using [ApiService].
abstract class const ApiNode() {
  List<ApiRoute> buildRoutes();
}

sealed class const ApiRoute({
  final RouteMatcher matcher = const AnyRouteMatcher(),
}) implements ApiNode {
  @override
  List<ApiRoute> buildRoutes() => [this];
}

abstract class const ApiEndpoint({super.matcher}) extends ApiRoute {
  Future<dynamic> onRequest(ApiRequest request);
}

abstract class const ApiMiddleware({
  super.matcher,
  required final List<ApiNode> routes,
  final bool catchRequests = false,
}) extends ApiRoute {
  Future<dynamic> onRequest(
    ApiRequest request,
    RequestHandler<ApiResponse> next,
  );
}

final class const ApiEndpointDelegate({
  super.matcher,
  final HttpRequestMethod? method,
  required final RequestHandler delegate,
}) extends ApiEndpoint {
  @override
  Future<ApiResponse> onRequest(ApiRequest request) async =>
      await delegate(request);
}

final class const ApiMiddlewareDelegate({
  super.matcher,
  required super.routes,
  required final MiddlewareRequestHandler delegate,
  super.catchRequests,
}) extends ApiMiddleware {
  @override
  Future<dynamic> onRequest(
    ApiRequest request,
    RequestHandler<ApiResponse> next,
  ) async => await delegate(request, next);
}
