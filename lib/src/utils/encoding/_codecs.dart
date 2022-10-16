part of 'transfer_codec.dart';

T _pass<T>(T e) => e;

String _encodeDateTime(DateTime e) => e.toIso8601String();

int _encodeDuration(Duration e) => e.inMilliseconds;

String _encodeUint8List(Uint8List e) => base64Encode(e);

String _decodeString(Object e) {
  if (e is String || e is num || e is bool) {
    return e.toString();
  } else {
    throw CodecException.typeMismatch(String, e.runtimeType);
  }
}

double _decodeDouble(Object e) {
  return double.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(double, e.runtimeType));
}

int _decodeInt(Object e) {
  return int.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(int, e.runtimeType));
}

num _decodeNum(Object e) {
  return num.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(num, e.runtimeType));
}

bool _decodeBool(Object e) {
  if (e is num) {
    return e > 0;
  }

  final str = e.toString().toLowerCase();
  if (str == 'true') {
    return true;
  } else if (str == 'false') {
    return false;
  }

  throw CodecException.typeMismatch(bool, e.runtimeType);
}

DateTime _decodeDateTime(Object e) {
  if (e is int) {
    return DateTime.fromMillisecondsSinceEpoch(e);
  }

  return DateTime.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(DateTime, e.runtimeType));
}

Duration _decodeDuration(Object e) {
  return int.tryParse(e.toString())
          ?.apply((millis) => Duration(milliseconds: millis)) ??
      (throw CodecException.typeMismatch(Duration, e.runtimeType));
}

Uint8List _decodeUint8List(Object e) {
  return e is String
      ? base64Decode(e)
      : (throw CodecException.typeMismatch(Uint8List, e.runtimeType));
}
