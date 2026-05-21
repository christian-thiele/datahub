import 'dart:typed_data';

enum ByteOrder {
  wkbXDR(0, Endian.big),
  wkbNDR(1, Endian.little);

  const ByteOrder(this.id, this.endian);

  final int id;
  final Endian endian;

  static ByteOrder read(int id) =>
      ByteOrder.values.firstWhere((e) => e.id == id);
}
