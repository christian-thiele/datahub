part of 'transfer_codec.dart';

T _pass<T>(T e) => e;

String _encodeDateTime(DateTime e) {
  if (e.isUtc) {
    return e.toIso8601String();
  } else {
    final prefix = e.timeZoneOffset.isNegative ? '-' : '+';
    return e.toIso8601String() +
        prefix +
        (e.timeZoneOffset.inHours.abs().toString().padLeft(2, '0')) +
        ':' +
        (e.timeZoneOffset.inMinutes % 60).toString().padLeft(2, '0');
  }
}

int _encodeDuration(Duration e) => e.inMilliseconds;

String _encodeUint8List(Uint8List e) => base64Encode(e);

String _decodeString(Object e, {String? name}) {
  if (e is String || e is num || e is bool) {
    return e.toString();
  } else {
    throw CodecException.typeMismatch(String, e.runtimeType, name);
  }
}

double _decodeDouble(Object e, {String? name}) {
  return double.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(double, e.runtimeType, name));
}

int _decodeInt(Object e, {String? name}) {
  return int.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(int, e.runtimeType, name));
}

num _decodeNum(Object e, {String? name}) {
  return num.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(num, e.runtimeType, name));
}

bool _decodeBool(Object e, {String? name}) {
  if (e is num) {
    return e > 0;
  }

  final str = e.toString().toLowerCase();
  if (str == 'true') {
    return true;
  } else if (str == 'false') {
    return false;
  }

  throw CodecException.typeMismatch(bool, e.runtimeType, name);
}

DateTime _decodeDateTime(Object e, {String? name}) {
  if (e is int) {
    return DateTime.fromMillisecondsSinceEpoch(e);
  }

  if (e is String) {
    final parsed = int.tryParse(e)?.apply(DateTime.fromMillisecondsSinceEpoch);
    if (parsed != null) {
      return parsed;
    }
  }

  return DateTime.tryParse(e.toString()) ??
      (throw CodecException.typeMismatch(DateTime, e.runtimeType, name));
}

Duration _decodeDuration(Object e, {String? name}) {
  return int.tryParse(e.toString())
          ?.apply((millis) => Duration(milliseconds: millis)) ??
      (throw CodecException.typeMismatch(Duration, e.runtimeType, name));
}

Uint8List _decodeUint8List(Object e, {String? name}) {
  return e is String
      ? base64Decode(e)
      : (throw CodecException.typeMismatch(Uint8List, e.runtimeType, name));
}
