import 'dart:async';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:http2/http2.dart' as http2;

import 'http_request.dart';
import 'http_response.dart';
import 'utils.dart';

abstract class HttpClient {
  final Uri address;
  bool get isHttp2;

  HttpClient(this.address);

  static Future<HttpClient> http11(Uri address,
      {io.SecurityContext? securityContext}) async {
    return _Http11Client(address, securityContext);
  }

  static Future<HttpClient> http2(
    Uri address, {
    io.SecurityContext? securityContext,
    bool Function(io.X509Certificate certificate)? onBadCertificate,
    Duration? timeout,
  }) async {
    var useSSL = address.scheme == 'https';
    if (useSSL) {
      var secureSocket = await io.SecureSocket.connect(
        address.host,
        address.port,
        supportedProtocols: ['h2'],
        onBadCertificate: onBadCertificate,
        context: securityContext,
        timeout: timeout,
      );

      if (secureSocket.selectedProtocol != 'h2') {
        throw Exception('Host does not support http2.');
      }

      return _Http2Client(address, secureSocket);
    } else {
      var socket = await io.Socket.connect(
        address.host,
        address.port,
        timeout: timeout,
      );

      return _Http2Client(address, socket);
    }
  }

  static Future<HttpClient> autodetect(
    Uri address, {
    io.SecurityContext? securityContext,
    bool Function(io.X509Certificate certificate)? onBadCertificate,
    Duration? timeout,
  }) async {
    var useSSL = address.scheme == 'https';
    if (useSSL) {
      try {
        var secureSocket = await io.SecureSocket.connect(
          address.host,
          address.port,
          supportedProtocols: ['h2'],
          onBadCertificate: onBadCertificate,
          context: securityContext,
          timeout: timeout,
        );

        if (secureSocket.selectedProtocol != 'h2') {
          return _Http11Client(address, securityContext);
        }

        return _Http2Client(address, secureSocket);
      } catch (e) {
        return _Http11Client(address, securityContext);
      }
    } else {
      return _Http11Client(address, securityContext);
    }
  }

  Future<HttpResponse> request(HttpRequest httpRequest);
}

class _Http11Client extends HttpClient {
  final _client = http.Client();
  final io.SecurityContext? securityContext;
  @override
  final bool isHttp2 = false;

  _Http11Client(super.address, this.securityContext);

  @override
  Future<HttpResponse> request(HttpRequest httpRequest) async {
    final request = http.StreamedRequest(
        httpRequest.method.name.toUpperCase(), httpRequest.requestUri);

    request.headers.addAll(httpRequest.headers
        .map((key, value) => MapEntry(key, value.join(', '))));

    httpRequest.bodyData.listen(
      request.sink.add,
      onError: request.sink.addError,
      onDone: request.sink.close,
      cancelOnError: true,
    );

    final response = await _client.send(request);

    return HttpResponse(
      httpRequest.requestUri,
      response.statusCode,
      response.headers.map((key, value) =>
          MapEntry(key, value.split(',').map((e) => e.trim()).toList())),
      response.stream,
    );
  }
}

class _Http2Client extends HttpClient {
  final io.Socket socket;
  final http2.ClientTransportConnection connection;
  @override
  final bool isHttp2 = true;

  _Http2Client(super.address, this.socket)
      : connection = http2.ClientTransportConnection.viaSocket(
          socket,
          settings: http2.ClientSettings(
            allowServerPushes: false,
          ),
        );

  @override
  Future<HttpResponse> request(HttpRequest httpRequest) async {
    final path = httpRequest.requestUri.hasQuery
        ? httpRequest.path + '?' + httpRequest.requestUri.query
        : httpRequest.path;

    final requestHeaders = [
      http2.Header.ascii(':method', httpRequest.method.name.toUpperCase()),
      http2.Header.ascii(':path', path),
      http2.Header.ascii(':scheme', httpRequest.requestUri.scheme),
      http2.Header.ascii(':authority', httpRequest.requestUri.host),
      ...httpRequest.headers.entries
          .expand((h) => h.value.map((v) => http2.Header.ascii(h.key, v))),
    ];

    var stream = connection.makeRequest(requestHeaders, endStream: false);

    httpRequest.bodyData.listen(
      stream.sendData,
      onError: (e) => stream.terminate,
      onDone: () => stream.outgoingMessages.close(),
      cancelOnError: true,
    );

    final bodyStream = StreamController<List<int>>(
      onCancel: () {
        stream.terminate();
      },
    );

    final response = Completer<HttpResponse>();
    stream.incomingMessages.listen(
      (event) {
        try {
          if (event is http2.HeadersStreamMessage) {
            final responseHeaders = http2Headers(event.headers);
            final statusCode =
                int.tryParse(responseHeaders.a[':status'] ?? '') ??
                    (throw Exception('Missing status code in response.'));

            if (event.endStream) {
              bodyStream.close();
            }

            response.complete(
              HttpResponse(
                httpRequest.requestUri,
                statusCode,
                responseHeaders.b,
                bodyStream.stream,
              ),
            );
          } else if (event is http2.DataStreamMessage) {
            bodyStream.add(event.bytes);
            if (event.endStream) {
              bodyStream.close();
            }
          }
        } catch (e, stack) {
          if (response.isCompleted) {
            if (!bodyStream.isClosed) {
              bodyStream.addError(e, stack);
              bodyStream.close();
            }
          } else {
            response.completeError(e);
          }
        }
      },
      onDone: () {
        if (!bodyStream.isClosed) {
          bodyStream.close();
        }
      },
      onError: (e, stack) {
        if (!response.isCompleted) {
          response.completeError(e);
        }
      },
      cancelOnError: false,
    );

    return await response.future;
  }
}
