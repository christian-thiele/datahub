import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';

class PlainAuthentication {
  final String username;
  final String password;

  PlainAuthentication({required this.username, required this.password});

  Uint8List toBytes() =>
      [0, ...utf8.encode(username), 0, ...utf8.encode(password)].asUint8List();
}
