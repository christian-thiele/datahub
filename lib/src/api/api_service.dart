import 'dart:async';
import 'dart:io';
import 'package:boost/boost.dart';

import 'package:cl_datahub/ioc.dart';
import 'package:cl_datahub/services.dart';
import 'package:cl_datahub/utils.dart';

import 'middleware/error_request_handler.dart';
import 'middleware/middleware.dart';
import 'middleware/request_handler.dart';
import 'sessions/session_provider.dart';
import 'sessions/session.dart';

import 'api_endpoint.dart';
import 'api_request.dart';
import 'api_request_exception.dart';
import 'api_request_method.dart';
import 'api_response.dart';
import 'request_context.dart';
import 'route.dart';

abstract class ApiService extends BaseService {
  late final _configAddress = config<String>('address', defaultValue: '');
  late final _configPort = config<int>('port', defaultValue: 8080);

  final String basePath;
  final List<ApiEndpoint> endpoints;
  final MiddlewareBuilder? middleware;
  final SessionProvider? sessionProvider;

  late Future _serveTask;
  final _shutdownToken = CancellationToken();

  ApiService(
    String? config,
    this.endpoints, {
    this.middleware,
    this.sessionProvider,
    String? apiBasePath,
  })  : basePath = _sanitizeBasePath(apiBasePath),
        super(config);

  Future<void> serve(dynamic address, int port,
      {CancellationToken? cancellationToken}) async {
    final _logService = resolve<LogService>();
    final server = await HttpServer.bind(address, port);

    _logService.info('Serving on $address:$port', sender: 'DataHub');

    final _cancelKey = cancellationToken?.attach(() {
      _logService.info('Shutting down...', sender: 'DataHub');
      server.close();
    });

    final completer = Completer();

    server.listen(_handleRequestGuarded, onError: _onError, onDone: () {
      cancellationToken?.detach(_cancelKey!);
      completer.complete();
    });

    await completer.future;
  }

  Future<void> _handleRequestGuarded(HttpRequest request) async {
    final stopWatch = Stopwatch()..start();
    try {
      var result = await handleRequest(request);

      result
          .getHeaders()
          .entries
          .forEach((h) => request.response.headers.add(h.key, h.value));

      request.response.statusCode = result.statusCode;
      await request.response.addStream(result.getData());

      //TODO cookies
    } on ApiRequestException catch (e) {
      // exceptions are usually handled at the ApiEndpoint and converted
      // to ApiResponses. this is just in case:
      request.response.statusCode = e.statusCode;
      request.response.write(
          '${e.statusCode} ${getHttpStatus(e.statusCode)}: ${e.message}');
    } catch (e, stack) {
      // exceptions are usually handled at the ApiEndpoint and converted
      // to ApiResponses. this is just in case:
      request.response.statusCode = 500;
      request.response.writeln('500 - Internal Server Error');

      var errorMessage = 'Error while handling request.';
      try {
        errorMessage = 'Error while handling request to "${request.uri}".';
      } catch (_) {}

      resolve<LogService>().error(
        errorMessage,
        sender: 'DataHub',
        error: e,
        trace: stack,
      );
    }

    stopWatch.stop();
    await request.response.close();
  }

  void _onError(dynamic e, StackTrace? trace) {
    resolve<LogService>().error(
      'Error while listening to socket.',
      sender: 'DataHub',
      error: e,
      trace: trace,
    );
  }

  Future<ApiResponse> handleRequest(HttpRequest httpRequest) async {
    final absolutePath = httpRequest.uri.path;
    final handler = _findRequestHandler(absolutePath);
    final path = absolutePath.substring(basePath.length);

    final headers = <String, List<String>>{};
    httpRequest.headers.forEach((name, values) {
      headers[name] = values;
    });

    final route = (handler is ApiEndpoint)
        ? handler.routePattern.decode(path)
        : Route(RoutePattern.any, path, {}, path);

    // find session
    Session? session;
    if (sessionProvider != null) {
      if (headers['session-token']?.isNotEmpty ?? false) {
        session =
            await sessionProvider!.redeemToken(headers['session-token']!.first);
      }
    }

    //TODO rethink RequestContext. not very sexy
    final context = RequestContext(sessionProvider, session);

    //TODO cookies

    final request = ApiRequest(
      context,
      parseMethod(httpRequest.method),
      route,
      headers,
      httpRequest.uri.queryParameters,
      httpRequest,
    );

    if (middleware != null) {
      return await middleware!.call(handler).handleRequest(request);
    } else {
      return await handler.handleRequest(request);
    }
  }

  @override
  Future<void> initialize() async {
    final serveAddress = nullOrWhitespace(_configAddress)
        ? InternetAddress.anyIPv4
        : _configAddress;

    _serveTask = serve(
      serveAddress,
      _configPort,
      cancellationToken: _shutdownToken,
    );
  }

  @override
  Future<void> shutdown() async {
    _shutdownToken.cancel();
    await _serveTask;
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
}
