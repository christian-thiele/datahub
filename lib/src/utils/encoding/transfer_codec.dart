import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';

import 'codec_exception.dart';
import 'encoding.dart';

part '_codecs.dart';

class TransferCodec<T> extends TypeCheck<T> {
  final dynamic Function(T) encode;
  final T Function(Object) decode;

  const TransferCodec(this.encode, this.decode);

  static const codecs = <TransferCodec>[
    TransferCodec<String>(_pass, _decodeString),
    TransferCodec<double>(_pass, _decodeDouble),
    TransferCodec<int>(_pass, _decodeInt),
    TransferCodec<num>(_pass, _decodeNum),
    TransferCodec<bool>(_pass, _decodeBool),
    TransferCodec<DateTime>(_encodeDateTime, _decodeDateTime),
    TransferCodec<Duration>(_encodeDuration, _decodeDuration),
    TransferCodec<Uint8List>(_encodeUint8List, _decodeUint8List),
    TransferCodec<List<String>>(encodeListTyped<List<String>, String>,
        decodeListTyped<List<String>, String>),
    TransferCodec<List<String?>>(encodeListTyped<List<String?>, String?>,
        decodeListTyped<List<String?>, String?>),
    TransferCodec<List<String>?>(encodeListTyped<List<String>?, String>,
        decodeListTyped<List<String>?, String>),
    TransferCodec<List<String?>?>(encodeListTyped<List<String?>?, String?>,
        decodeListTyped<List<String?>?, String?>),
    TransferCodec<List<int>>(
        encodeListTyped<List<int>, int>, decodeListTyped<List<int>, int>),
    TransferCodec<List<int?>>(
        encodeListTyped<List<int?>, int?>, decodeListTyped<List<int?>, int?>),
    TransferCodec<List<int>?>(
        encodeListTyped<List<int>?, int>, decodeListTyped<List<int>?, int>),
    TransferCodec<List<int?>?>(
        encodeListTyped<List<int?>?, int?>, decodeListTyped<List<int?>?, int?>),
    TransferCodec<List<double>>(encodeListTyped<List<double>, double>,
        decodeListTyped<List<double>, double>),
    TransferCodec<List<double?>>(encodeListTyped<List<double?>, double?>,
        decodeListTyped<List<double?>, double?>),
    TransferCodec<List<double>?>(encodeListTyped<List<double>?, double>,
        decodeListTyped<List<double>?, double>),
    TransferCodec<List<double?>?>(encodeListTyped<List<double?>?, double?>,
        decodeListTyped<List<double?>?, double?>),
    TransferCodec<List<bool>>(
        encodeListTyped<List<bool>, bool>, decodeListTyped<List<bool>, bool>),
    TransferCodec<List<bool?>>(encodeListTyped<List<bool?>, bool?>,
        decodeListTyped<List<bool?>, bool?>),
    TransferCodec<List<bool>?>(
        encodeListTyped<List<bool>?, bool>, decodeListTyped<List<bool>?, bool>),
    TransferCodec<List<bool?>?>(encodeListTyped<List<bool?>?, bool?>,
        decodeListTyped<List<bool?>?, bool?>),
  ];

  static TransferCodec<T>? find<T>() =>
      codecs.firstOrNullWhere((c) => c.matches<T>()) as TransferCodec<T>?;

  bool matches<TOther>() =>
      isExact<TOther>() || TypeCheck<T?>().isExact<TOther>();
}
