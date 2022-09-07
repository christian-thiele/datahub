import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class DetachedSocket extends Stream<Uint8List> implements Socket {
  final Stream<Uint8List> _incoming;
  final Socket _socket;

  DetachedSocket(this._socket, this._incoming);

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _incoming.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Encoding get encoding => _socket.encoding;

  @override
  set encoding(Encoding value) {
    _socket.encoding = value;
  }

  @override
  void write(Object? obj) {
    _socket.write(obj);
  }

  @override
  void writeln([Object? obj = '']) {
    _socket.writeln(obj);
  }

  @override
  void writeCharCode(int charCode) {
    _socket.writeCharCode(charCode);
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    _socket.writeAll(objects, separator);
  }

  @override
  void add(List<int> bytes) {
    _socket.add(bytes);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _socket.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) {
    return _socket.addStream(stream);
  }

  @override
  void destroy() {
    _socket.destroy();
  }

  @override
  Future flush() => _socket.flush();

  @override
  Future close() => _socket.close();

  @override
  Future get done => _socket.done;

  @override
  int get port => _socket.port;

  @override
  InternetAddress get address => _socket.address;

  @override
  InternetAddress get remoteAddress => _socket.remoteAddress;

  @override
  int get remotePort => _socket.remotePort;

  @override
  bool setOption(SocketOption option, bool enabled) {
    return _socket.setOption(option, enabled);
  }

  @override
  Uint8List getRawOption(RawSocketOption option) {
    return _socket.getRawOption(option);
  }

  @override
  void setRawOption(RawSocketOption option) {
    _socket.setRawOption(option);
  }
}
