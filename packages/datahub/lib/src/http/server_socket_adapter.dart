import 'dart:async';
import 'dart:io' as io;

class ServerSocketAdapter._(
  @override final io.InternetAddress address,
  @override final int port,
  final StreamController<io.Socket> _controller,
) extends StreamView<io.Socket> implements io.ServerSocket {
  this : super(_controller.stream);

  factory(io.InternetAddress address, int port) {
    return ServerSocketAdapter._(address, port, StreamController<io.Socket>());
  }

  void add(io.Socket socket) => _controller.add(socket);

  @override
  Future<io.ServerSocket> close() async {
    await _controller.close();
    return this;
  }
}
