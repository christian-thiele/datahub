import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:flutter/cupertino.dart';

typedef AuthCallbackResult = ({String code, String state});

Future<AuthCallbackResult> listenForAuthCallback(
  Uri redirectUri, [
  CancellationToken? cancel,
]) async {
  if (redirectUri.host != 'localhost' && redirectUri.host != '127.0.0.1') {
    throw ApiError('redirectUri host must be loopback');
  }

  final completer = Completer<AuthCallbackResult>();
  final server = HttpServer(
    await ServerSocket.bind(InternetAddress.loopbackIPv4, redirectUri.port),
    (request) async {
      if (request.requestUri.path != redirectUri.path) {
        return HttpResponse(
          request.requestUri,
          HttpStatus.forbidden,
          {},
          Stream.empty(),
        );
      }

      if (request.queryParams.containsKey('code') &&
          request.queryParams.containsKey('state')) {
        completer.complete((
          code: request.queryParams['code']!.first,
          state: request.queryParams['state']!.first,
        ));
        // TODO nice html
        return HttpResponse(
          request.requestUri,
          200,
          {
            'content-type': ['text/html'],
          },
          Stream.value(
            utf8.encode(
              '<!DOCTYPE><html><head><title>Aperture</title></head><body><p>You can close this page now.</p></body></html>',
            ),
          ),
        );
      } else {
        completer.completeError(
          ApiException('Invalid response from identity provider.'),
        );
        return HttpResponse(
          request.requestUri,
          400,
          {},
          Stream.value(
            utf8.encode(
              '<!DOCTYPE><html><head><title>Aperture</title></head><body><p>There was an error trying to sign you in.</p></body></html>',
            ),
          ),
        );
      }
    },
    (error, stack) => completer.completeError(error, stack),
    (error, stack) => completer.completeError(error, stack),
    (error, stack) => completer.completeError(error, stack),
  );

  try {
    return await completer.future.cancelOn(cancel);
  } finally {
    try {
      await server.close();
    } catch (e) {
      debugPrint('Could not close HttpServer: $e');
    }
  }
}
