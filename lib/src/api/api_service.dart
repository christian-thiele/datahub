import 'dart:async';
import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/api/request_context.dart';

abstract class ApiService extends BaseService {
  late final _configAddress = config<String>('address', defaultValue: '');
  late final _configPort = config<int>('port', defaultValue: 8080);

  final List<ApiEndpoint> endpoints;
  final MiddlewareBuilder? middleware;
  final SessionProvider? sessionProvider;

  late Future _serveTask;
  final _shutdownToken = CancellationToken();

  ApiService(String? config, this.endpoints,
      {this.middleware, this.sessionProvider})
      : super(config);

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
      resolve<LogService>().error(
        'Error while handling request to "${request.requestedUri}".',
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
    //TODO strip api base path (like /v1)
    final path = httpRequest.requestedUri.path;
    final resource = endpoints.firstWhere(
        (element) => element.routePattern.match(path),
        orElse: () => throw ApiRequestException.notFound(
            'Resource \"$path\" not found.'));
    final method = parseMethod(httpRequest.method);

    final route = resource.routePattern.decode(httpRequest.uri.path);

    // get query params
    final queryParams = httpRequest.uri.queryParameters;

    // get headers
    final headers = <String, List<String>>{};
    httpRequest.headers.forEach((name, values) {
      headers[name] = values;
    });

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

    final request =
        ApiRequest(context, method, route, headers, queryParams, httpRequest);

    if (middleware != null) {
      return await middleware!.call(resource).handleRequest(request);
    } else {
      return await resource.handleRequest(request);
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
}
