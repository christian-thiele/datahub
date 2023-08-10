import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/collection.dart';
import 'package:datahub/transfer_object.dart';

class OrderedDataCodec {
  static Uint8List encode<Item>(List<OrderedData<Item>> items) {
    final payloads = items
        .map((item) => Tuple(item, jsonEncode(item.data).apply(utf8.encode)));
    final data = Uint8List(
        16 * payloads.length + payloads.fold(0, (p, e) => p + e.b.length));
    var pos = 0;
    for (final payload in payloads) {
      final byteData = ByteData.sublistView(data);
      byteData.setInt64(pos, payload.a.order);
      byteData.setInt64(pos += 8, payload.b.length);
      data.setRange(pos += 8, pos += payload.b.length, payload.b);
    }
    return data;
  }

  static List<OrderedData<Item>> decode<Item>(
      List<int> data, TransferBean<Item> bean) {
    var pos = 0;
    final byteData = ByteData.sublistView(data.asUint8List());
    final items = <OrderedData<Item>>[];
    while (pos < data.length) {
      final order = byteData.getInt64(pos);
      final length = byteData.getInt64(pos += 8);
      final payload = data.getRange(pos += 8, pos += length).toList();
      items.add(
          OrderedData(order, bean.toObject(jsonDecode(utf8.decode(payload)))));
    }
    return items;
  }
}
