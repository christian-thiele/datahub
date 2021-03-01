import 'dart:math';
import 'dart:typed_data';

class Token {
  Uint8List bytes;

  Token() : bytes = _generate();

  @override
  String toString() {
    return bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _generate() {
    final data = ByteData(16);
    final random = Random.secure();

    data.setInt64(0, DateTime.now().microsecondsSinceEpoch);
    for(var i=0; i<8; i++) {
      data.setInt8(8+i, random.nextInt(256));
    }

    return data.buffer.asUint8List();
  }
}