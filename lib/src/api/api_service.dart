import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:boost/boost.dart';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';
import 'package:http2/transport.dart';

import 'http/http_request.dart';
import 'http/http_server.dart';
import 'middleware/error_request_handler.dart';
import 'middleware/middleware.dart';
import 'middleware/request_handler.dart';
import 'sessions/session_provider.dart';
import 'sessions/session.dart';

import 'api_endpoint.dart';
import 'api_request.dart';
import 'api_request_exception.dart';
import 'api_response.dart';
import 'request_context.dart';
import 'route.dart';

abstract class ApiService extends BaseService {
  final _logService = resolve<LogService>();
  late final _configAddress = config<String?>('address');
  late final _configPort = config<int?>('port') ?? 8080;
  late final HttpServer _server;

  final String basePath;
  final List<ApiEndpoint> endpoints;
  final MiddlewareBuilder? middleware;
  final SessionProvider? sessionProvider;

  ApiService(
    String? config,
    this.endpoints, {
    this.middleware,
    this.sessionProvider,
    String? apiBasePath,
  })  : basePath = _sanitizeBasePath(apiBasePath),
        super(config);

  @override
  Future<void> initialize() async {
    final serveAddress = nullOrWhitespace(_configAddress)
        ? io.InternetAddress.anyIPv4
        : _configAddress;

    final context = io.SecurityContext()
      ..setAlpnProtocols(['h2', 'h2-14', 'http/1.1'], true)
      ..useCertificateChain('test/hub/localhost.crt')
      ..usePrivateKey('test/hub/localhost.key');

    final socket =
        await io.SecureServerSocket.bind(serveAddress, _configPort, context);

    _server = HttpServer(socket, _onError, _onStreamError);
    _server.http1Requests.listen(_handleRequestHttp1);
    _server.http2Streams.listen(_handleStreamHttp2);
  }

  Future<void> _handleRequestHttp1(io.HttpRequest request) async {
    try {
      var result = await handleRequest(HttpRequest.http1(request));

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

      _logService.error(
        errorMessage,
        sender: 'DataHub',
        error: e,
        trace: stack,
      );
    }

    await request.response.close();
  }

  Future<void> _handleStreamHttp2(ServerTransportStream stream) async {
    try {
      final dataController = StreamController<List<int>>();
      final requestCompleter = Completer<HttpRequest>();
      final terminated = CancellationToken();

      stream.onTerminated = (_) => terminated.cancel();

      stream.incomingMessages.listen(
        (event) async {
          if (event is HeadersStreamMessage) {
            if (event.endStream) {
              unawaited(dataController.close());
            }

            requestCompleter
                .complete(HttpRequest.http2(event, dataController.stream));
          } else if (event is DataStreamMessage) {
            dataController.add(event.bytes);
            if (event.endStream) {
              unawaited(dataController.close());
            }
          }
        },
        onError: _onStreamError,
      );

      final request = await requestCompleter.future;

      try {
        final response = await handleRequest(request);
        if (terminated.cancellationRequested) {
          throw Exception('Remote closed stream.');
        }

        stream.sendHeaders([
          Header.ascii(':status', response.statusCode.toString()),
          ...response
              .getHeaders()
              .entries
              .map((h) => Header.ascii(h.key.toLowerCase(), h.value)),
        ]);

        await for (final chunk in response.getData()) {
          if (terminated.cancellationRequested) {
            throw Exception('Remote closed stream.');
          }
          stream.sendData(chunk);
        }
      } on ApiRequestException catch (e) {
        // exceptions are usually handled at the ApiEndpoint and converted
        // to ApiResponses. this is just in case:
        if (!terminated.cancellationRequested) {
          stream
              .sendHeaders([Header.ascii(':status', e.statusCode.toString())]);
          stream.sendData(utf8.encode(
              '${e.statusCode} ${getHttpStatus(e.statusCode)}: ${e.message}'));
        }
      } catch (e, stack) {
        // exceptions are usually handled at the ApiEndpoint and converted
        // to ApiResponses. this is just in case:
        var errorMessage = 'Error while handling request.';
        try {
          errorMessage = 'Error while handling request to "${request.path}".';
        } catch (_) {}

        _logService.error(
          errorMessage,
          sender: 'DataHub',
          error: e,
          trace: stack,
        );

        if (!terminated.cancellationRequested) {
          stream.sendHeaders([Header.ascii(':status', '500')]);
          stream.sendData(utf8.encode('500 - Internal Server Error'));
        }
      } finally {
        await stream.outgoingMessages.close();
      }
    } catch (e, stack) {
      _logService.error(
        'Error while handling HTTP2 stream.',
        sender: 'DataHub',
        error: e,
        trace: stack,
      );
    }
  }

  Future<ApiResponse> handleRequest(HttpRequest httpRequest) async {
    final handler = _findRequestHandler(httpRequest.path);
    final path = httpRequest.path.startsWith(basePath)
        ? httpRequest.path.substring(basePath.length)
        : '';

    final route = (handler is ApiEndpoint)
        ? handler.routePattern.decode(path)
        : Route(RoutePattern.any, path, {}, path);

    // find session
    Session? session;
    if (sessionProvider != null) {
      final authorization = (httpRequest.headers['Authorization'] ??
          httpRequest.headers['authorization']);
      if (authorization?.isNotEmpty ?? false) {
        session = await sessionProvider!.redeemToken(authorization!.first);
      }
    }

    //TODO rethink RequestContext. not very sexy
    final context = RequestContext(sessionProvider, session);

    //TODO cookies

    final request = ApiRequest(
      context,
      httpRequest.method,
      route,
      httpRequest.headers,
      httpRequest.queryParams,
      httpRequest.bodyData,
    );

    if (middleware != null) {
      return await middleware!.call(handler).handleRequest(request);
    } else {
      return await handler.handleRequest(request);
    }
  }

  void _onError(dynamic e, StackTrace? trace) {
    resolve<LogService>().error(
      'Error while listening to socket.',
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

  @override
  Future<void> shutdown() async {
    await _server.close();
  }
}
