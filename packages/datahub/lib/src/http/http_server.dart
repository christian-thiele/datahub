import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/src/http/http_response.dart';
import 'package:datahub/src/http/server_socket_adapter.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';
import 'package:http2/http2.dart' as http2;

import 'http_connection.dart';
import 'http_request.dart';

typedef HttpRequestHandler = Future<HttpResponse> Function(HttpRequest);

/// HTTP/1.1 and HTTP/2 server.
///
/// Every request is traced in a span of kind server (unless [enableTracing]
/// is false or there is no [Telemetry]), which continues the trace of the
/// caller if the request has a `traceparent` header. Handlers can add to
/// this span (e.g. `http.route`) via [Tracer.currentSpan].
class HttpServer {
  static const _knownMethods = {
    'CONNECT',
    'DELETE',
    'GET',
    'HEAD',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
    'TRACE',
  };

  final dynamic _serverSocket;
  final HttpRequestHandler requestHandler;
  final void Function(dynamic error, StackTrace stack) onSocketError;
  final void Function(dynamic error, StackTrace stack) onProtocolError;
  final void Function(dynamic error, StackTrace stack) onStreamError;
  final bool enableTracing;

  late final _http1Adapter = ServerSocketAdapter(
    _serverSocket.address,
    _serverSocket.port,
  );

  late final io.HttpServer _http1;

  final _http2Connections = <http2.ServerTransportConnection>{};
  final _http2Finishing = <Future<void>>[];
  bool _stopped = false;

  HttpServer(
    this._serverSocket,
    this.requestHandler,
    this.onSocketError,
    this.onProtocolError,
    this.onStreamError, {
    this.enableTracing = true,
  }) {
    if (_serverSocket is! io.ServerSocket &&
        _serverSocket is! io.SecureServerSocket) {
      throw Exception('No server socket.');
    }

    _serverSocket.listen(
      (socket) {
        socket.setOption(io.SocketOption.tcpNoDelay, true);
        if (socket is io.SecureSocket) {
          log.trace(
            'Incoming secure connection with selected protocol ${socket.selectedProtocol}.',
          );
          // ALPN first
          switch (socket.selectedProtocol) {
            case 'h2':
            case 'h2-14':
              _handleHttp2Socket(socket);
              return;
            case 'http/1.1':
            case null:
              // default to http1.1
              _http1Adapter.add(socket);
              return;
            default:
              socket.destroy();
              throw ApiException(
                'Unexpected ALPN protocol: ${socket.selectedProtocol}.',
              );
          }
        } else {
          HttpConnection.detectProtocol(
            socket,
            _http1Adapter.add,
            _handleHttp2Socket,
            onProtocolError,
          );
        }
      },
      onDone: _socketDone,
      onError: onSocketError,
      cancelOnError: false,
    );

    _http1 = io.HttpServer.listenOn(_http1Adapter);
    _http1.listen(_handleHttp1RequestTraced);
  }

  Future<void> _handleHttp1RequestTraced(io.HttpRequest request) {
    String? header(String name) => switch (request.headers[name]) {
      [final value] => value,
      _ => null,
    };

    return _traced(
      method: request.method,
      uri: request.uri,
      protocolVersion: request.protocolVersion,
      parent: TraceContext.parse(header(TraceContext.traceparentHeader)),
      userAgent: header(io.HttpHeaders.userAgentHeader),
      handle: (span) => _handleHttp1Request(request, span),
    );
  }

  /// Runs [handle] in a server span, according to the semantic conventions
  /// for HTTP server spans.
  Future<void> _traced({
    required String method,
    required Uri uri,
    required String protocolVersion,
    required Span? parent,
    required String? userAgent,
    required Future<void> Function(LocalSpan? span) handle,
  }) async {
    final telemetry = enableTracing
        ? Context.maybeOfZone()?.find(Find<Telemetry?>())
        : null;
    if (telemetry == null) {
      return await handle(null);
    }

    final knownMethod = _knownMethods.contains(method) ? method : '_OTHER';
    await telemetry.trace(
      knownMethod == '_OTHER' ? 'HTTP' : knownMethod,
      type: SpanType.server,
      parent: parent,
      attributes: {
        'http.request.method': knownMethod,
        if (knownMethod != method) 'http.request.method_original': method,
        'url.path': nullOrWhitespace(uri.path) ? '/' : uri.path,
        'url.scheme': _serverSocket is io.SecureServerSocket ? 'https' : 'http',
        'network.protocol.version': protocolVersion,
        'server.port': _serverSocket.port,
        'user_agent.original': ?userAgent,
      },
      handle,
    );
  }

  /// Adds the status code to [span], status codes >= 500 fail it.
  static void _recordStatus(LocalSpan? span, int statusCode) {
    if (span == null) {
      return;
    }

    span.setAttribute('http.response.status_code', statusCode);
    if (statusCode >= 500) {
      if (!span.attributes.containsKey('error.type')) {
        span.setAttribute('error.type', statusCode.toString());
      }
      span.setError();
    }
  }

  static void _recordException(
    LocalSpan? span,
    Object error,
    StackTrace stack,
  ) {
    if (span == null) {
      return;
    }

    span.recordException(error, stack: stack);
    if (!span.attributes.containsKey('error.type')) {
      span.setAttribute('error.type', error.runtimeType.toString());
    }
    _recordStatus(span, 500);
  }

  Future<void> _handleHttp1Request(
    io.HttpRequest request,
    LocalSpan? span,
  ) async {
    try {
      var result = await requestHandler(HttpRequest.http1(request));
      _recordStatus(span, result.statusCode);

      for (var h in result.headers.entries) {
        request.response.headers.add(h.key, h.value);
      }

      request.response.statusCode = result.statusCode;

      //TODO cookies

      if (result is UpgradeHttpResponse) {
        final socket = await request.response.detachSocket(writeHeaders: true);
        result.socketHandler(socket);
        return;
      }

      await request.response.addStream(result.bodyData);
    } catch (e, stack) {
      _recordException(span, e, stack);
      try {
        request.response.statusCode = 500;
        if (Context.maybeOfZone()?.environment == Environment.dev) {
          request.response.writeln('500 - Internal Server Error\n$e\n$stack');
        } else {
          request.response.writeln('500 - Internal Server Error');
        }
      } on StateError catch (stateError) {
        log.warn('Could not send error response.', error: stateError);
      }

      var errorMessage = 'Error while handling request.';
      try {
        errorMessage = 'Error while handling request to "${request.uri}".';
      } catch (_) {}

      log.error(errorMessage, error: e, stack: stack);
    }

    await request.response.close();
  }

  void _handleHttp2Socket(io.Socket socket) {
    if (_stopped) {
      socket.destroy();
      return;
    }

    final connection = http2.ServerTransportConnection.viaSocket(socket);
    _http2Connections.add(connection);
    connection.incomingStreams.listen(
      _handleHttp2Stream,
      onError: onStreamError,
      onDone: () => _http2Connections.remove(connection),
    );
  }

  Future<void> _handleHttp2Stream(http2.ServerTransportStream stream) async {
    try {
      final dataController = StreamController<List<int>>();
      final requestCompleter = Completer<HttpRequest>();
      final terminated = CancellationToken();

      unawaited(stream.outgoingMessages.done.then((_) => terminated.cancel()));
      stream.onTerminated = (_) => terminated.cancel();

      final incomingSubscription = stream.incomingMessages.listen(
        (event) async {
          if (event is http2.HeadersStreamMessage) {
            if (event.endStream) {
              unawaited(dataController.close());
            }

            if (requestCompleter.isCompleted) {
              // trailers
              return;
            }
            try {
              requestCompleter.complete(
                HttpRequest.http2(event, dataController.stream),
              );
            } catch (e, stack) {
              requestCompleter.completeError(e, stack);
            }
          } else if (event is http2.DataStreamMessage) {
            dataController.add(event.bytes);
            if (event.endStream) {
              unawaited(dataController.close());
            }
          }
        },
        onDone: dataController.close,
        onError: (e, stack) => onStreamError(e, stack),
      );

      final HttpRequest request;
      try {
        request = await requestCompleter.future;
      } catch (e) {
        log.debug('Invalid HTTP2 request.', error: e);
        stream.sendHeaders([
          http2.Header.ascii(':status', '400'),
        ], endStream: true);
        await incomingSubscription.cancel();
        return;
      }

      await _traced(
        method: request.method.name.toUpperCase(),
        uri: request.requestUri,
        protocolVersion: '2',
        parent: TraceContext.fromHeaders(request.headers),
        userAgent: request.headers[io.HttpHeaders.userAgentHeader]?.firstOrNull,
        handle: (span) => _respondHttp2(
          stream,
          request,
          terminated,
          incomingSubscription,
          span,
        ),
      );
    } catch (e, stack) {
      log.error('Error while handling HTTP2 stream.', error: e, stack: stack);
    }
  }

  Future<void> _respondHttp2(
    http2.ServerTransportStream stream,
    HttpRequest request,
    CancellationToken terminated,
    StreamSubscription<http2.StreamMessage> incomingSubscription,
    LocalSpan? span,
  ) async {
    try {
      final response = await requestHandler(request);
      _recordStatus(span, response.statusCode);
      if (terminated.cancellationRequested) {
        throw Exception('Remote closed stream.');
      }

      if (response is UpgradeHttpResponse) {
        // websockets over HTTP/2 require extended CONNECT (RFC 8441),
        // which is not implemented
        throw ApiException('Connection upgrade is not supported over HTTP/2.');
      }

      final headers = [
        http2.Header.ascii(':status', response.statusCode.toString()),
        ...response.headers.entries.expand(
          (h) => h.value.map((v) => http2.Header.ascii(h.key.toLowerCase(), v)),
        ),
      ];

      stream.sendHeaders(headers);

      final responseBodyComplete = Completer();
      final responseBodySubscription = response.bodyData.listen(
        stream.sendData,
        onDone: responseBodyComplete.complete,
        onError: responseBodyComplete.completeError,
      );

      terminated.attach(responseBodySubscription.cancel);
      await responseBodyComplete.future;

      //## PUSH STREAM ?
      /*if (stream.canPush && response is PushStreamResponse) {
          final subscription = response.pushStream.listen(
            (event) async {
              final pushTerminated = CancellationToken();
              try {
                final pushStream = stream.push([
                  http2.Header.ascii(':method', 'GET'),
                  http2.Header.ascii(':authority', 'localhost:8080'),
                  http2.Header.ascii(':path', request.path),
                ]);
                pushStream.onTerminated = (_) => pushTerminated.cancel();

                if (!pushTerminated.cancellationRequested) {
                  pushStream.sendHeaders([
                    http2.Header.ascii(':status', event.statusCode.toString()),
                    ...event.getHeaders().entries.expand((h) => h.value.map(
                        (v) => http2.Header.ascii(h.key.toLowerCase(), v))),
                  ]);
                }

                await for (final chunk in event.getData()) {
                  if (pushTerminated.cancellationRequested) {
                    throw Exception('Remote closed stream.');
                  }
                  pushStream.sendData(chunk);
                }
                await pushStream.outgoingMessages.close();
              } catch (_) {
                pushTerminated.cancel();
              }
            },
            onError: (e) {
              print('Error in push stream: $e'); //TODO how to handle??
              //probably last error response, then close
            },
            onDone: () async {
              terminated.cancel();
              await stream.outgoingMessages.close();
            },
          );
          terminated.attach(subscription.cancel);
        } else {
          await stream.outgoingMessages.close();
        }*/
      //## PUSH STREAM ?

      await stream.outgoingMessages.close();
    } catch (e, stack) {
      // exceptions are usually handled at the ApiEndpoint and converted
      // to ApiResponses. this is just in case:
      _recordException(span, e, stack);
      var errorMessage = 'Error while handling request.';
      try {
        errorMessage = 'Error while handling request to "${request.path}".';
      } catch (_) {}

      log.error(errorMessage, error: e, stack: stack);

      if (!terminated.cancellationRequested) {
        stream.sendHeaders([http2.Header.ascii(':status', '500')]);
        if (Context.maybeOfZone()?.environment == Environment.dev) {
          stream.sendData(
            utf8.encode('500 - Internal Server Error\n$e\n$stack'),
          );
        } else {
          stream.sendData(utf8.encode('500 - Internal Server Error'));
        }
      }

      await stream.outgoingMessages.close();
    } finally {
      // Stop receiving request data the handler did not consume, so it
      // does not accumulate in [dataController]. Since the outgoing side
      // is already closed at this point, this resets the stream if the
      // remote is still sending data.
      await incomingSubscription.cancel();
    }
  }

  void _socketDone() async {
    await _http1.close();
  }

  /// Stops accepting new connections and new requests, while allowing
  /// requests that are currently being handled to complete.
  ///
  /// The server socket is closed, idle HTTP/1.1 keep-alive connections are
  /// closed (active ones are closed after their current request) and HTTP/2
  /// connections are finished gracefully via GOAWAY, closing as soon as all
  /// of their active streams are done.
  Future<void> stopAccepting() async {
    if (_stopped) {
      return;
    }
    _stopped = true;

    await _serverSocket.close();
    await _http1.close();
    for (final connection in _http2Connections.toList()) {
      _http2Finishing.add(connection.finish().catchError((_) {}));
    }
  }

  /// Closes the [HttpServer] and its [io.ServerSocket].
  ///
  /// Waits for requests that are currently being handled to complete, unless
  /// [force] is true, in which case active connections are closed
  /// immediately.
  Future<void> close({bool force = false}) async {
    await stopAccepting();
    if (force) {
      await _http1.close(force: true);
      await Future.wait(_http2Connections.toList().map((c) => c.terminate()));
    } else {
      await Future.wait(_http2Finishing);
    }
  }
}
