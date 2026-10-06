import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:boost/boost.dart';

abstract class BaseId {
  static final _random = Random();

  final Uint8List _id;

  const BaseId(this._id);

  String get hexId => _id.toHexString();

  String get base64Id => base64Encode(_id);

  UnmodifiableListView<int> get bytes =>
      UnmodifiableListView(_id); // _id.asUnmodifiableView();

  /// Whether at least one byte is not zero, ids of only zeros are invalid
  /// according to the W3C Trace Context.
  bool get isValid => _id.any((b) => b != 0);

  /// Random bytes that are not all zero.
  static Uint8List generateBytes(int length) {
    final bytes = Uint8List(length);
    do {
      for (var i = 0; i < length; i++) {
        bytes[i] = _random.nextInt(256);
      }
    } while (bytes.every((b) => b == 0));
    return bytes;
  }

  /// Parses [hex] (lowercase, [length] bytes) or returns null.
  static Uint8List? parseHex(String? hex, int length) {
    if (hex == null || hex.length != length * 2) {
      return null;
    }
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      final byte = int.tryParse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      if (byte == null) {
        return null;
      }
      bytes[i] = byte;
    }
    return bytes;
  }

  @override
  bool operator ==(Object other) =>
      other is BaseId &&
      other.runtimeType == runtimeType &&
      other._id.length == _id.length &&
      Iterable.generate(_id.length).every((i) => other._id[i] == _id[i]);

  @override
  int get hashCode => Object.hashAll(_id);

  @override
  String toString() => hexId;
}
