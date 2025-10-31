import 'dart:io';

class Connection {
  static const protocolHeader = [65, 77, 81, 80, 0, 9, 1, 0];

  static const methodStart = 10;
  static const methodStartOk = 11;
  static const methodSecure = 20;
  static const methodSecureOk = 21;
  static const methodTune = 30;
  static const methodTuneOk = 31;
  static const methodOpen = 40;
  static const methodOpenOk = 41;
  static const methodClose = 50;
  static const methodCloseOk = 51;

  bool _isOpen = true;

  Connection._();

  static Future<Connection> open({
    required String host,
    required int port,
  }) async {
    final socket = await Socket.connect(host, port);
    socket.add(protocolHeader);
    return Connection._();
  }
}
