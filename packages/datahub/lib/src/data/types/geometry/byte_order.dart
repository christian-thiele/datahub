import 'dart:typed_data';

enum ByteOrder(final int id, final Endian endian) {
  wkbXDR(0, Endian.big),
  wkbNDR(1, Endian.little);

  static ByteOrder read(int id) => ByteOrder.values.firstWhere(
    (e) => e.id == id,
    orElse: () => throw FormatException('Unknown WKB byte order: $id'),
  );
}
