import 'dart:async';
import 'dart:io' as io;
import 'package:boost/boost.dart';
import 'package:datahub/config.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/http.dart';
import 'package:datahub/scaffold.dart';

import 'api_request.dart';
import 'api_request_exception.dart';
import 'api_response.dart';
import 'api_route.dart';

/// A Service that serves HTTP-Requests.
///
/// The ApiService uses the datahub [HTTPServer], therefore supports
/// HTTP 1.1 and HTTP 2 connections.
class ApiService implements Service {
  final Config<String?> address;
  final Config<int> port;
  final List<ApiNode> routes;
  final io.SecurityContext? securityContext;

  ApiService({
    this.address = const Config<String?>('address'),
    this.port = const Config<int>('port', defaultValue: 8080),
    required this.routes,
    this.securityContext,
  });

  @override
  ServiceInstance<ApiService> createInstance() => _ApiServiceInstance();
}

class _ApiServiceInstance extends ServiceInstance<ApiService> {
  late final HttpServer _server;
  late final List<ApiRoute> _routes;

  @override
  FutureOr<void> initialize() async {
    _routes = service.routes.expand((e) => e.buildRoutes()).toList();

    final serveAddress = nullOrWhitespace(read(service.address))
        ? io.InternetAddress.anyIPv4
        : read(service.address);

    final socket = service.securityContext != null
        ? await io.SecureServerSocket.bind(
            serveAddress,
            read(service.port),
            service.securityContext,
          )
        : await io.ServerSocket.bind(serveAddress, read(service.port));

    _server = HttpServer(
      socket,
      handleRequest,
      _onSocketError,
      _onProtocolError,
      _onStreamError,
    );
  }

  Future<HttpResponse> handleRequest(HttpRequest httpRequest) async {
    try {
      final request = ApiRequest(
        httpRequest.requestUri,
        httpRequest.method,
        httpRequest.headers,
        <String, String>{},
        httpRequest.bodyData,
      );

      final (handler, routeParams) = findEndpoint(_routes, request);
      request.routeParams.addAll(routeParams);
      final response = await handler(request);
      return response.toHttpResponse(httpRequest.requestUri);
    } on ApiRequestException catch (e) {
      return e.toResponse().toHttpResponse(httpRequest.requestUri);
    } catch (e, stack) {
      if (Context.ofZone().environment == Environment.dev) {
        return DebugResponse(
          e,
          stack,
          500,
        ).toHttpResponse(httpRequest.requestUri);
      } else {
        return ApiRequestException.internalError(
          'Internal Server Error',
        ).toResponse().toHttpResponse(httpRequest.requestUri);
      }
    }
  }

  static (RequestHandler, Map<String, String>) findEndpoint(
    List<ApiRoute> routes,
    ApiRequest request,
  ) {
    if (tryFindEndpoint(routes, request) case final endpoint?) {
      return endpoint;
    } else {
      return exceptionHandler(ApiRequestException.notFound());
    }
  }

  static (RequestHandler, Map<String, String>)? tryFindEndpoint(
    List<ApiRoute> routes,
    ApiRequest request,
  ) {
    final matching = routes.where((r) => r.matcher.matches(request));
    final handlers = matching.map((r) {
      return switch (r) {
        ApiEndpoint(:final onRequest) => (
          wrapDynamic(onRequest),
          r.matcher.getRouteParams(request),
        ),
        ApiMiddleware(:final routes, :final onRequest, :final catchRequests) =>
          wrapWithMiddleware(
            onRequest,
            catchRequests
                ? findEndpoint(routes, request)
                : tryFindEndpoint(routes, request),
            r.matcher.getRouteParams(request),
          ),
      };
    });

    return handlers.nonNulls.firstOrNull;
  }

  static (RequestHandler, Map<String, String>) exceptionHandler(
    ApiRequestException exception,
  ) {
    return ((request) => exception.toResponse(), {});
  }

  static RequestHandler<ApiResponse> wrapDynamic(RequestHandler handler) {
    return (request) async => ApiResponse.dynamic(await handler(request));
  }

  static (RequestHandler<ApiResponse>, Map<String, String>)? wrapWithMiddleware(
    MiddlewareRequestHandler middlewareHandler,
    (RequestHandler, Map<String, String>)? next,
    Map<String, String> routeParams,
  ) {
    if (next != null) {
      return (
        wrapDynamic(
          (request) async =>
              await middlewareHandler(request, wrapDynamic(next.$1)),
        ),
        {...routeParams, ...next.$2},
      );
    } else {
      return null;
    }
  }

  void _onSocketError(dynamic e, StackTrace? trace) {
    log.error('Error while listening to socket.', error: e, stack: trace);
  }

  void _onProtocolError(dynamic e, StackTrace? trace) {
    log.warn('Error during protocol negotiation.', error: e, stack: trace);
  }

  void _onStreamError(dynamic e, StackTrace? trace) {
    log('Error while handling HTTP2 stream.\n$e');
  }

  @override
  FutureOr<void> dispose() async {
    await _server.close();
  }
}
