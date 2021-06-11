import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/request_context.dart';
import 'package:cl_datahub/src/api/middleware/middleware.dart';
import 'package:cl_datahub/src/api/sessions/session_provider.dart';
import 'package:cl_datahub/utils.dart';

import 'api_response.dart';
import 'sessions/memory_session.dart';
import 'sessions/session.dart';

abstract class ApiBase {
  final List<ApiEndpoint> endpoints;
  final MiddlewareBuilder? middleware;
  final SessionProvider? sessionProvider;

  const ApiBase(this.endpoints, {this.middleware, this.sessionProvider});

  Future<void> serve(String address, int port,
      {CancellationToken? cancellationToken}) async {
    final server = await HttpServer.bind(address, port);

    _log('Serving on $address:$port');

    final _cancelKey = cancellationToken?.attach(() {
      print('Shutting down...');
      server.close();
    });

    final completer = Completer();

    server.listen(_handleRequestGuarded, onError: _onError, onDone: () {
      cancellationToken?.detach(_cancelKey!);
      completer.complete();
    });

    await completer.future;
  }

  void _log(String message) => print(message);

  Future<void> _handleRequestGuarded(HttpRequest request) async {
    try {
      final stopWatch = Stopwatch()..start();
      var result = await handleRequest(request);
      stopWatch.stop();
      print(
          'Handled request to ${request.requestedUri} in ${stopWatch.elapsedMilliseconds}ms.');

      result
          .getHeaders()
          .entries
          .forEach((h) => request.response.headers.add(h.key, h.value));

      request.response.statusCode = result.statusCode;
      request.response.add(result.getData());

      //TODO cookies
    } on ApiRequestException catch (e) {
      // exceptions are usually handled at the ApiEndpoint and converted
      // to ApiResponses. this is just in case:
      request.response.statusCode = e.statusCode;
      request.response.write(
          '${e.statusCode} ${getHttpStatus(e.statusCode)}: ${e.message}');
    } catch (e) {
      // exceptions are usually handled at the ApiEndpoint and converted
      // to ApiResponses. this is just in case:
      request.response.statusCode = 500;
      request.response.writeln('500 - Internal Server Error');
    }

    await request.response.close();
  }

  void _onError(dynamic e) {
    print(e);
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

    // get body data
    final bodyBytes = Uint8List.fromList(
        (await httpRequest.toList()).expand((element) => element).toList());

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
        ApiRequest(context, method, route, headers, queryParams, bodyBytes);

    return await () async {
      if (middleware != null) {
        return await middleware!.call(resource).handleRequest(request);
      } else {
        return await resource.handleRequest(request);
      }
    }();
  }
}
