import 'dart:async';

import 'package:datahub/http.dart';

import 'api_request.dart';
import 'api_response.dart';
import 'route_matcher.dart';

typedef RequestHandler<T> = FutureOr<T> Function(ApiRequest request);
typedef MiddlewareRequestHandler<T> =
    FutureOr<T> Function(
      ApiRequest request,
      RequestHandler<ApiResponse> handler,
    );

/// Building-block for defining the structure of APIs using [ApiService].
abstract class ApiNode {
  const ApiNode();

  List<ApiRoute> buildRoutes();
}

sealed class ApiRoute implements ApiNode {
  final RouteMatcher matcher;

  const ApiRoute({this.matcher = const AnyRouteMatcher()});

  @override
  List<ApiRoute> buildRoutes() => [this];
}

abstract class ApiEndpoint extends ApiRoute {
  const ApiEndpoint({super.matcher});

  Future<dynamic> onRequest(ApiRequest request);
}

abstract class ApiMiddleware extends ApiRoute {
  final List<ApiRoute> routes;
  final bool catchRequests;

  const ApiMiddleware({
    super.matcher,
    required this.routes,
    this.catchRequests = false,
  });

  Future<dynamic> onRequest(
    ApiRequest request,
    RequestHandler<ApiResponse> next,
  );
}

final class ApiEndpointDelegate extends ApiEndpoint {
  final HttpRequestMethod? method;
  final RequestHandler delegate;

  const ApiEndpointDelegate({
    super.matcher,
    this.method,
    required this.delegate,
  });

  @override
  Future<ApiResponse> onRequest(ApiRequest request) async =>
      await delegate(request);
}

final class ApiMiddlewareDelegate extends ApiMiddleware {
  final MiddlewareRequestHandler delegate;

  const ApiMiddlewareDelegate({
    super.matcher,
    required super.routes,
    required this.delegate,
    super.catchRequests,
  });

  @override
  Future<dynamic> onRequest(
    ApiRequest request,
    RequestHandler<ApiResponse> next,
  ) async => await delegate(request, next);
}
