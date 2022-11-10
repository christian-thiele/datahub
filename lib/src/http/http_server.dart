import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/src/http/http_response.dart';
import 'package:datahub/src/http/server_socket_adapter.dart';
import 'package:datahub/utils.dart';
import 'package:http2/http2.dart' as http2;

import 'http_connection.dart';
import 'http_request.dart';

typedef HttpRequestHandler = Future<HttpResponse> Function(HttpRequest);

class HttpServer {
  final _logService = resolve<LogService>();
  final dynamic _serverSocket;
  final HttpRequestHandler requestHandler;
  final void Function(dynamic error, StackTrace stack) onSocketError;
  final void Function(dynamic error, StackTrace stack) onProtocolError;
  final void Function(dynamic error, StackTrace stack) onStreamError;

  late final _http1Adapter =
      ServerSocketAdapter(_serverSocket.address, _serverSocket.port);

  late final io.HttpServer _http1;

  HttpServer(
    this._serverSocket,
    this.requestHandler,
    this.onSocketError,
    this.onProtocolError,
    this.onStreamError,
  ) {
    if (_serverSocket is! io.ServerSocket &&
        _serverSocket is! io.SecureServerSocket) {
      throw Exception('No server socket.');
    }

    _serverSocket.listen(
      (socket) {
        socket.setOption(io.SocketOption.tcpNoDelay, true);
        if (socket is io.SecureSocket) {
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
    _http1.listen(_handleHttp1Request);
  }

  Future<void> _handleHttp1Request(io.HttpRequest request) async {
    try {
      var result = await requestHandler(HttpRequest.http1(request));

      result.headers.entries
          .forEach((h) => request.response.headers.add(h.key, h.value));

      request.response.statusCode = result.statusCode;
      await request.response.addStream(result.bodyData);

      //TODO cookies
    } catch (e, stack) {
      request.response.statusCode = 500;
      if (resolve<ConfigService>().environment == Environment.dev) {
        request.response.writeln('500 - Internal Server Error\n$e\n$stack');
      } else {
        request.response.writeln('500 - Internal Server Error');
      }

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

  void _handleHttp2Socket(io.Socket socket) {
    final connection = http2.ServerTransportConnection.viaSocket(socket);
    connection.incomingStreams.listen(
      _handleHttp2Stream,
      onError: onStreamError,
    );
  }

  void _handleHttp2Stream(http2.ServerTransportStream stream) async {
    try {
      final dataController = StreamController<List<int>>();
      final requestCompleter = Completer<HttpRequest>();
      final terminated = CancellationToken();

      stream.onTerminated = (_) {
        terminated.cancel();
      };

      stream.incomingMessages.listen(
        (event) async {
          if (event is http2.HeadersStreamMessage) {
            if (event.endStream) {
              unawaited(dataController.close());
            }

            requestCompleter
                .complete(HttpRequest.http2(event, dataController.stream));
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

      final request = await requestCompleter.future;

      try {
        final response = await requestHandler(request);
        if (terminated.cancellationRequested) {
          throw Exception('Remote closed stream.');
        }

        final headers = [
          http2.Header.ascii(':status', response.statusCode.toString()),
          ...response.headers.entries.expand((h) =>
              h.value.map((v) => http2.Header.ascii(h.key.toLowerCase(), v))),
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
          stream.sendHeaders([http2.Header.ascii(':status', '500')]);
          if (resolve<ConfigService>().environment == Environment.dev) {
            stream.sendData(
                utf8.encode('500 - Internal Server Error\n$e\n$stack'));
          } else {
            stream.sendData(utf8.encode('500 - Internal Server Error'));
          }
        }

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

  void _socketDone() async {
    await _http1.close();
  }

  /// Closes the [HttpServer] and its [io.ServerSocket].
  Future<void> close() async {
    await _serverSocket.close();
  }
}
