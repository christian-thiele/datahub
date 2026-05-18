import 'dart:io' as io;

import 'package:datahub/api.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/http.dart';

/// Utility for testing [ApiService] endpoints in unit tests.
///
/// Lets users find an [Api] (ServiceInstance of [ApiService]) and connect
/// to it automatically.
extension TestClient on Api {
  RestClient connectHttp11({
    HttpAuth? auth,
    io.SecurityContext? securityContext,
    Duration? timeout,
  }) {
    return RestClient.connectHttp11(
      Uri(scheme: 'http', host: address.host, port: port),
      auth: auth,
      securityContext: securityContext,
    );
  }

  RestClient connectHttp2({
    HttpAuth? auth,
    io.SecurityContext? securityContext,
    Duration? timeout,
  }) {
    return RestClient.connectHttp2(
      Uri(scheme: 'http', host: address.host, port: port),
      auth: auth,
      securityContext: securityContext,
      timeout: timeout,
    );
  }
}
