import 'dart:async';
import 'dart:io' as io;

class ServerSocketAdapter extends StreamView<io.Socket>
    implements io.ServerSocket {
  @override
  final io.InternetAddress address;

  @override
  final int port;

  final StreamController<io.Socket> _controller;

  ServerSocketAdapter._(this.address, this.port, this._controller)
      : super(_controller.stream);

  factory ServerSocketAdapter(io.InternetAddress address, int port) {
    return ServerSocketAdapter._(address, port, StreamController<io.Socket>());
  }

  void add(io.Socket socket) => _controller.add(socket);

  @override
  Future<io.ServerSocket> close() async {
    await _controller.close();
    return this;
  }
}
