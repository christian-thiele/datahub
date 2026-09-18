import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/utils/auth_callback_page.dart';
import 'package:flutter/cupertino.dart';

typedef AuthCallbackResult = ({String code, String state});

Future<AuthCallbackResult> listenForAuthCallback(
  Uri redirectUri,
  ApertureBootstrap bootstrap, [
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

      final success =
          request.queryParams.containsKey('code') &&
          request.queryParams.containsKey('state');
      if (success) {
        completer.complete((
          code: request.queryParams['code']!.first,
          state: request.queryParams['state']!.first,
        ));
      } else {
        completer.completeError(
          ApiException('Invalid response from identity provider.'),
        );
      }

      final page = await renderAuthCallbackPage(bootstrap, success: success);
      return HttpResponse(
        request.requestUri,
        success ? HttpStatus.ok : HttpStatus.badRequest,
        {
          'content-type': ['text/html; charset=utf-8'],
        },
        Stream.value(utf8.encode(page)),
      );
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
