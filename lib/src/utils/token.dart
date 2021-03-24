import 'dart:math';
import 'dart:typed_data';
import 'package:boost/boost.dart';

class Token {
  final Uint8List bytes;

  /// Generates a new unique token.
  Token() : bytes = _generate();

  /// Instantiates a token object with given data.
  Token.withBytes(this.bytes) : assert(bytes.length == 16);

  @override
  bool operator ==(Object other) {
    if (other is Token) {
      return bytes.sequenceEquals(other.bytes);
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _generate() {
    final data = ByteData(16);
    final random = Random.secure();

    data.setInt64(0, DateTime.now().microsecondsSinceEpoch);
    for (var i = 0; i < 8; i++) {
      data.setInt8(8 + i, random.nextInt(256));
    }

    return data.buffer.asUint8List();
  }
}
