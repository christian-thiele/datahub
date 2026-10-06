import 'dart:async';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/config.dart';
import 'package:datahub/http.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'api_request.dart';
import 'api_response.dart';
import 'api_route.dart';
import 'request_logger.dart';

abstract interface class Api {
  late final io.InternetAddress address;
  late final int port;
}

/// A Service that serves HTTP-Requests.
///
/// The ApiService uses the datahub [HTTPServer], therefore supports
/// HTTP 1.1 and HTTP 2 connections.
class ApiService implements Service {
  final Find<Telemetry> telemetry;
  final Config<String?> address;
  final Config<int> port;

  /// Maximum number of requests served concurrently.
  ///
  /// When this many requests are in flight, further requests are rejected
  /// immediately with `503 Service Unavailable` instead of being handled.
  /// This provides overload protection through backpressure. Null means
  /// unlimited.
  final Config<int?> concurrentRequestLimit;

  /// Maximum duration to wait for active requests to complete when the
  /// service is disposed.
  ///
  /// During shutdown, no new requests are accepted and requests currently
  /// being served are given this much time to complete. Connections that
  /// are still active after the timeout are closed forcefully.
  final Config<Duration> shutdownTimeout;

  final Config<bool> enableMetrics;
  final Config<String> metricPrefix;

  /// Whether requests and responses are logged at trace level.
  ///
  /// Each request is logged when it arrives (method, path, query and
  /// headers) and again once its response has been sent (status, duration,
  /// response headers and both bodies), so the response record can be read
  /// on its own. Both records are logged within the span of the request and
  /// use OpenTelemetry semantic conventions for their labels (e.g.
  /// `http.request.method`, `url.path`, `http.response.status_code`).
  ///
  /// Credentials in headers and query parameters are redacted, but bodies
  /// are logged as they are and may contain sensitive data.
  final Config<bool> logRequests;

  /// Maximum number of bytes logged per request and response body when
  /// [logRequests] is enabled. Longer bodies are truncated.
  ///
  /// Set to 0 to log body sizes only.
  final Config<int> logRequestsBodyLimit;

  /// Names of headers whose values are redacted when [logRequests] is
  /// enabled, e.g. custom credential headers. Matched case-insensitively.
  ///
  /// These are redacted in addition to `authorization`,
  /// `proxy-authorization`, `cookie`, `set-cookie` and `x-api-key`, which are
  /// always redacted.
  final Config<List<String>> logRequestsRedactedHeaders;

  final List<ApiNode> routes;
  final io.SecurityContext? securityContext;

  const ApiService({
    this.address = const Config('address'),
    this.port = const Config('port', defaultValue: 8080),
    this.concurrentRequestLimit = const Config('concurrentRequestLimit'),
    this.shutdownTimeout = const Config<Duration>(
      'shutdownTimeout',
      defaultValue: Duration(seconds: 30),
    ),
    this.enableMetrics = const Config<bool>(
      'enableMetrics',
      defaultValue: true,
    ),
    this.metricPrefix = const Config<String>(
      'metricPrefix',
      defaultValue: 'api',
    ),
    this.logRequests = const Config<bool>('logRequests', defaultValue: false),
    this.logRequestsBodyLimit = const Config<int>(
      'logRequestsBodyLimit',
      defaultValue: 1024,
    ),
    this.logRequestsRedactedHeaders = const Config<List<String>>(
      'logRequestsRedactedHeaders',
      defaultValue: [],
    ),
    required this.routes,
    this.securityContext,
    this.telemetry = const Find(),
  });

  @override
  ServiceInstance<ApiService> createInstance() => _ApiServiceInstance();
}

class _ApiServiceInstance extends ServiceInstance<ApiService> implements Api {
  late final HttpServer _server;
  late final List<ApiRoute> _routes;
  late final int? _concurrentRequestLimit;
  late final Duration _shutdownTimeout;
  late final GaugeMetric? _activeRequestsMetric;
  late final CounterMetric? _rejectedRequestsMetric;
  int _activeRequests = 0;
  bool _disposing = false;

  late final Telemetry telemetry;

  @override
  late final io.InternetAddress address;

  @override
  late final int port;

  @override
  Future<void> initialize() async {
    await super.initialize();
    telemetry = find(service.telemetry);
    _concurrentRequestLimit = read(service.concurrentRequestLimit);
    _shutdownTimeout = read(service.shutdownTimeout);
    if (read(service.enableMetrics)) {
      final prefix = read(service.metricPrefix);
      _activeRequestsMetric = telemetry.gauge(
        '${prefix}_active_requests',
        help: 'Number of requests currently being served.',
      );
      _rejectedRequestsMetric = telemetry.counter(
        '${prefix}_requests_rejected',
        help:
            'Number of requests rejected because the concurrent '
            'request limit was reached.',
      );
    } else {
      _activeRequestsMetric = null;
      _rejectedRequestsMetric = null;
    }
    _routes = service.routes.expand((e) => e.buildRoutes()).toList();

    final serveAddress = nullOrWhitespace(read(service.address))
        ? io.InternetAddress.anyIPv4
        : read(service.address);
    final servePort = read(service.port);

    final socket = service.securityContext != null
        ? await io.SecureServerSocket.bind(
            serveAddress,
            servePort,
            service.securityContext,
          )
        : await io.ServerSocket.bind(serveAddress, servePort);

    address = switch (socket) {
      io.ServerSocket(:final address) => address,
      io.SecureServerSocket(:final address) => address,
      _ => throw UnsupportedError('Invalid server socket type.'),
    };

    port = switch (socket) {
      io.ServerSocket(:final port) => port,
      io.SecureServerSocket(:final port) => port,
      _ => throw UnsupportedError('Invalid server socket type.'),
    };

    final requestLogger = read(service.logRequests)
        ? RequestLogger(
            bodyLimit: read(service.logRequestsBodyLimit),
            redactedHeaders: read(service.logRequestsRedactedHeaders),
          )
        : null;

    log.info('Listening on ${address.address}:$port');
    _server = HttpServer(
      socket,
      switch (requestLogger) {
        final logger? => (request) => logger.handle(request, handleRequest),
        null => handleRequest,
      },
      _onSocketError,
      _onProtocolError,
      _onStreamError,
    );
  }

  Future<HttpResponse> handleRequest(HttpRequest httpRequest) async {
    if (_disposing) {
      _rejectedRequestsMetric?.inc();
      return ApiRequestException.serviceUnavailable()
          .toResponse()
          .toHttpResponse(httpRequest.requestUri);
    }

    if (_concurrentRequestLimit case final int limit
        when _activeRequests >= limit) {
      _rejectedRequestsMetric?.inc();
      return ApiRequestException.serviceUnavailable()
          .toResponse()
          .toHttpResponse(httpRequest.requestUri);
    }

    _activeRequests++;
    _activeRequestsMetric?.set(_activeRequests);
    try {
      return await _handleRequest(httpRequest);
    } finally {
      _activeRequests--;
      _activeRequestsMetric?.set(_activeRequests);
    }
  }

  Future<HttpResponse> _handleRequest(HttpRequest httpRequest) async {
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

      final method = httpRequest.method.name.toUpperCase();
      final route = routeParams['#pattern'];

      // attributes and status according to the semantic conventions for
      // HTTP server spans
      return await telemetry.trace(
        route == null ? method : '$method $route',
        type: SpanType.server,
        attributes: {
          'http.request.method': method,
          'http.route': ?route,
          'url.path': httpRequest.path,
          'url.scheme': service.securityContext == null ? 'http' : 'https',
        },
        (span) async {
          final ApiResponse response;
          try {
            response = await handler(request);
          } on ApiRequestException catch (e) {
            span.addAttribute('http.response.status_code', e.statusCode);
            if (e.statusCode >= 500) {
              span.addAttribute('error.type', e.statusCode.toString());
              rethrow;
            }

            // client errors do not fail server spans
            span.addExceptionEvent(e, setError: false);
            return e.toResponse().toHttpResponse(httpRequest.requestUri);
          } catch (e) {
            span.addAttribute('http.response.status_code', 500);
            span.addAttribute('error.type', e.runtimeType.toString());
            rethrow;
          }

          span.addAttribute('http.response.status_code', response.statusCode);
          if (response.statusCode >= 500) {
            span.addAttribute('error.type', response.statusCode.toString());
            span.setHasError();
          }
          return response.toHttpResponse(httpRequest.requestUri);
        },
      );
    } on ApiRequestException catch (e, stack) {
      if (e.statusCode >= 500 && e.statusCode < 600) {
        log.error(
          'Request failed with internal error.',
          error: e,
          stack: stack,
          labels: {
            'http.method': httpRequest.method.name.toUpperCase().toString(),
            'http.path': httpRequest.path,
            'http.status_code': e.statusCode.toString(),
          },
        );
      }
      return e.toResponse().toHttpResponse(httpRequest.requestUri);
    } catch (e, stack) {
      log.error(
        'Request failed with internal error.',
        error: e,
        stack: stack,
        labels: {
          'http.method': httpRequest.method.name.toUpperCase().toString(),
          'http.path': httpRequest.path,
          'http.status_code': '500',
        },
      );
      // ignore: datahub_lints/avoid_zone_context_in_service
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
    return tryFindEndpoint(routes, request) ??
        exceptionHandler(ApiRequestException.notFound());
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
                ? findEndpoint([
                    ...routes.expand((e) => e.buildRoutes()),
                  ], request)
                : tryFindEndpoint([
                    ...routes.expand((e) => e.buildRoutes()),
                  ], request),
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
  Future<void> dispose() async {
    _disposing = true;
    await _server.stopAccepting();

    final watch = Stopwatch()..start();
    while (_activeRequests > 0 && watch.elapsed < _shutdownTimeout) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (_activeRequests > 0) {
      log.warn(
        '$_activeRequests request(s) still active after shutdown timeout '
        '($_shutdownTimeout). Closing connections forcefully.',
      );
      await _server.close(force: true);
    } else {
      try {
        await _server.close().timeout(_shutdownTimeout - watch.elapsed);
      } on TimeoutException {
        log.warn(
          'Open connections did not close within the shutdown timeout. '
          'Closing connections forcefully.',
        );
        await _server.close(force: true);
      }
    }

    await super.dispose();
  }
}
