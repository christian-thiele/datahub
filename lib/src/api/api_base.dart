import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/api_request_exception.dart';
import 'package:cl_datahub/src/api/api_request_method.dart';
import 'package:cl_datahub/src/utils/utils.dart';

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

  Future<dynamic> handleRequest(HttpRequest request) async {
    final path = request.requestedUri.path;
    final resource = endpoints.firstWhere((element) => element.matchRoute(path),
        orElse: () => throw ApiRequestException.notFound(
            'Resource \"$path\" not found.'));
    final method = parseMethod(request.method);

    final urlParams = decodeRoute(resource.path, request.uri.path);
    final queryParams = request.uri.queryParameters;
    final bodyBytes = Uint8List.fromList(
        (await request.toList()).expand((element) => element).toList());

    switch (method) {
      case ApiRequestMethod.GET:
        return resource.get(urlParams, queryParams);
      case ApiRequestMethod.POST:
        return resource.post(urlParams, queryParams, bodyBytes);
      case ApiRequestMethod.PUT:
        return resource.put(urlParams, queryParams, bodyBytes);
      case ApiRequestMethod.PATCH:
        return resource.patch(urlParams, queryParams, bodyBytes);
      case ApiRequestMethod.DELETE:
        return resource.delete(urlParams, queryParams);
    }
  }
}
