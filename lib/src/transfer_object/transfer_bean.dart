import 'dart:convert';

import 'package:datahub/utils.dart';

abstract class TransferBean<T> {
  late final codec = TransferCodec<T>(toMap, _decode);

  TransferBean();

  Map<String, dynamic> toMap(T transferObject);

  T toObject(Map<String, dynamic> data, {String? name});

  T _decode(dynamic value, {String? name}) {
    if (value is Map<String, dynamic>) {
      return toObject(value, name: name);
    } else if (value is String) {
      return _decode(jsonDecode(value), name: name);
    } else if (value is List<int>) {
      return _decode(utf8.decode(value), name: name);
    } else {
      throw CodecException.typeMismatch(T, value.runtimeType, name);
    }
  }
}

/// Bean for use with simple Map<String, dynamic> objects.
class MapTransferBean extends TransferBean<Map<String, dynamic>> {
  MapTransferBean();

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> transferObject) =>
      transferObject;

  @override
  Map<String, dynamic> toObject(Map<String, dynamic> data, {String? name}) =>
      data;
}
