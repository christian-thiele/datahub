import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'geometry.dart';

class Polygon extends Geometry {
  final List<LineString> rings;

  Polygon(int? srid, this.rings, bool hasZ, bool hasM)
      : super(srid, GeometryType.polygon, hasZ, hasM);

  factory Polygon.read(int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return Polygon(
      srid,
      List.generate(
        length,
        (i) => LineString.read(srid, reader, hasZ, hasM),
      ),
      hasZ,
      hasM,
    );
  }

  @override
  Uint8List toBytes(ByteOrder byteOrder) {
    final bytes = ByteDataWriter(endian: byteOrder.endian);
    bytes.writeUint32(rings.length);
    for (final ring in rings) {
      bytes.write(ring.toBytes(byteOrder));
    }
    return bytes.toBytes();
  }

  @override
  String toString() {
    final buffer = StringBuffer('POLYGON ');
    if (hasZ) {
      buffer.write('Z');
    }
    if (hasM) {
      buffer.write('M');
    }

    if (hasZ || hasM) {
      buffer.write(' ');
    }

    buffer.write(toText());
    return buffer.toString();
  }

  String toText() {
    return '(${rings.map((e) => e.toText()).join(',')})';
  }
}
