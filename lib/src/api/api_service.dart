import 'dart:async';
import 'dart:io' as io;
import 'dart:math';
import 'package:boost/boost.dart';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/http.dart';

import 'middleware/error_request_handler.dart';
import 'middleware/middleware.dart';
import 'middleware/request_handler.dart';

import 'api_endpoint.dart';
import 'api_request.dart';
import 'api_request_exception.dart';
import 'api_response.dart';
import 'route.dart';

class ApiService extends BaseService {
  late final address = config<String?>('address');
  late final port = config<int?>('port') ?? 8080;
  late final HttpServer _server;

  final String basePath;
  final List<ApiEndpoint> endpoints;
  final MiddlewareBuilder? middleware;
  final io.SecurityContext? securityContext;

  ApiService(
    String? config,
    this.endpoints, {
    this.middleware,
    String? apiBasePath,
    this.securityContext,
  })  : basePath = _sanitizeBasePath(apiBasePath),
        super(config);

  @override
  Future<void> initialize() async {
    final serveAddress =
        nullOrWhitespace(address) ? io.InternetAddress.anyIPv4 : address;

    final socket = securityContext != null
        ? await io.SecureServerSocket.bind(serveAddress, port, securityContext)
        : await io.ServerSocket.bind(serveAddress, port);

    _server = HttpServer(socket, handleRequest, _onSocketError,
        _onProtocolError, _onStreamError);
  }

  Future<HttpResponse> handleRequest(HttpRequest httpRequest) async {
    return await runZoned(
      () async {
        try {
          final handler = _findRequestHandler(httpRequest.path);
          final path = httpRequest.path.startsWith(basePath)
              ? httpRequest.path.substring(basePath.length)
              : '';

          final route = (handler is ApiEndpoint)
              ? handler.routePattern.decode(path)
              : Route(RoutePattern.any, path, {}, path);

          //TODO cookies

          final request = ApiRequest(
            httpRequest.method,
            route,
            httpRequest.headers,
            httpRequest.queryParams,
            httpRequest.bodyData,
            null,
          );

          final response = await (middleware?.call(handler) ?? handler)
              .handleRequest(request);

          return response.toHttpResponse(httpRequest.requestUri);
        } on ApiRequestException catch (e) {
          // Exceptions should have been handled by ApiEndpoint, this is just
          // to make sure
          return e.toResponse().toHttpResponse(httpRequest.requestUri);
        } catch (e, stack) {
          // Exceptions should have been handled by ApiEndpoint, this is just
          // to make sure
          if (resolve<ConfigService>().environment == Environment.dev) {
            return DebugResponse(e, stack, 500)
                .toHttpResponse(httpRequest.requestUri);
          } else {
            return ApiRequestException.internalError('Internal Server Error')
                .toResponse()
                .toHttpResponse(httpRequest.requestUri);
          }
        }
      },
      zoneValues: {
        #apiRequestId: _generateRequestId(),
      },
    );
  }

  void _onSocketError(dynamic e, StackTrace? trace) {
    resolve<LogService>().error(
      'Error while listening to socket.',
      sender: 'DataHub',
      error: e,
      trace: trace,
    );
  }

  void _onProtocolError(dynamic e, StackTrace? trace) {
    resolve<LogService>().warn(
      'Error during protocol negotiation.',
      sender: 'DataHub',
      error: e,
      trace: trace,
    );
  }

  void _onStreamError(dynamic e, StackTrace? trace) {
    resolve<LogService>().verbose(
      'Error while handling HTTP2 stream.\n$e',
      sender: 'DataHub',
    );
  }

  // TODO this could be part of RoutePattern instead
  static String _sanitizeBasePath(String? apiBasePath) {
    if (nullOrWhitespace(apiBasePath)) {
      return '';
    }

    if (!apiBasePath!.startsWith('/')) {
      apiBasePath = '/$apiBasePath';
    }

    apiBasePath = apiBasePath.replaceAll(RegExp(r'\/+'), '/');

    if (apiBasePath.endsWith('/')) {
      apiBasePath = apiBasePath.substring(0, apiBasePath.length - 1);
    }

    return apiBasePath;
  }

  RequestHandler _findRequestHandler(String absolutePath) {
    if (!absolutePath.startsWith(basePath)) {
      return ErrorRequestHandler(ApiRequestException.notFound(
          'Resource \"$absolutePath\" not found.'));
    }

    final path = absolutePath.substring(basePath.length);

    return endpoints
            .firstOrNullWhere((element) => element.routePattern.match(path)) ??
        ErrorRequestHandler(ApiRequestException.notFound(
            'Resource \"$absolutePath\" not found.'));
  }

  static String _generateRequestId() {
    final r = Random();
    return Iterable.generate(
        4, (_) => r.nextInt(255).toRadixString(16).padLeft(2, '0')).join(':');
  }

  @override
  Future<void> shutdown() async {
    await _server.close();
  }
}
