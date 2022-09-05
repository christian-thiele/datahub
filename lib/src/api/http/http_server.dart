import 'dart:async';
import 'dart:io' as io;

import 'package:datahub/datahub.dart';
import 'package:datahub/src/api/http/server_socket_adapter.dart';
import 'package:http2/http2.dart' as http2;

import 'http_connection.dart';

class HttpServer {
  final dynamic _serverSocket;
  final void Function(dynamic error, StackTrace stack) onSocketError;
  final void Function(dynamic error, StackTrace stack) onStreamError;

  late final _http1Adapter =
      ServerSocketAdapter(_serverSocket.address, _serverSocket.port);

  late final io.HttpServer _http1;
  final _http2 = StreamController<http2.ServerTransportStream>();

  Stream<io.HttpRequest> get http1Requests => _http1;

  Stream<http2.ServerTransportStream> get http2Streams => _http2.stream;

  HttpServer(
    this._serverSocket,
    this.onSocketError,
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
          );
        }
      },
      onDone: _socketDone,
      onError: onSocketError,
      cancelOnError: true,
    );

    _http1 = io.HttpServer.listenOn(_http1Adapter);
  }

  void _socketDone() async {
    await Future.wait([_http1.close(), _http2.close()]);
  }

  /// Closes the [HttpServer] and its [io.ServerSocket].
  Future<void> close() async {
    await _serverSocket.close();
  }

  void _handleHttp2Socket(io.Socket socket) {
    final connection = http2.ServerTransportConnection.viaSocket(socket);
    connection.incomingStreams.listen(
      _http2.add,
      onError: onStreamError,
    );
  }
}
