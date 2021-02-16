import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/utils.dart';

import 'api_response.dart';

abstract class ApiBase {
  final List<ApiEndpoint> endpoints;

  const ApiBase(this.endpoints);

  Future serve(String address, int port,
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

  Future _handleRequestGuarded(HttpRequest request) async {
    try {
      var result = await handleRequest(request);

      if (result is! ApiResponse) {
        result = ApiResponse.dynamic(result);
      }

      result
          .getHeaders()
          .entries
          .forEach((h) => request.response.headers.add(h.key, h.value));

      request.response.add(result.getData());
    } on ApiRequestException catch (e) {
      request.response.statusCode = e.statusCode;
      request.response.write(
          '${e.statusCode} ${getHttpStatus(e.statusCode)}: ${e.message}');
    } catch (e) {
      request.response.statusCode = 500;
      request.response.writeln('500 - Internal Server Error');
    }

    await request.response.close();
  }

  void _onError(dynamic e) {
    print(e);
  }

  Future<dynamic> handleRequest(HttpRequest httpRequest) async {
    //TODO strip api base path (like /v1)
    final path = httpRequest.requestedUri.path;
    final resource = endpoints.firstWhere(
        (element) => element.routePattern.match(path),
        orElse: () => throw ApiRequestException.notFound(
            'Resource \"$path\" not found.'));
    final method = parseMethod(httpRequest.method);

    final route = resource.routePattern.decode(httpRequest.uri.path);
    final queryParams = httpRequest.uri.queryParameters;
    final bodyBytes = Uint8List.fromList(
        (await httpRequest.toList()).expand((element) => element).toList());

    final request = ApiRequest(method, route, queryParams, bodyBytes);

    switch (method) {
      case ApiRequestMethod.GET:
        return resource.get(request);
      case ApiRequestMethod.POST:
        return resource.post(request);
      case ApiRequestMethod.PUT:
        return resource.put(request);
      case ApiRequestMethod.PATCH:
        return resource.patch(request);
      case ApiRequestMethod.DELETE:
        return resource.delete(request);
    }
  }
}
