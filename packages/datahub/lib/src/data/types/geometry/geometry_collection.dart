import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'geometry.dart';

class GeometryCollection extends Geometry {
  final List<Geometry> geometry;

  GeometryCollection(int? srid, this.geometry, bool hasZ, bool hasM)
      : super(srid, GeometryType.geometryCollection, hasZ, hasM);

  factory GeometryCollection.read(
      int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return GeometryCollection(
      srid,
      List.generate(length, (i) => Geometry.read(srid, reader, hasZ, hasM)),
      hasZ,
      hasM,
    );
  }

  @override
  Uint8List toBytes(ByteOrder byteOrder) {
    final bytes = ByteDataWriter(endian: byteOrder.endian);
    bytes.writeUint32(geometry.length);
    for (final ring in geometry) {
      bytes.write(ring.toBytes(byteOrder));
    }
    return bytes.toBytes();
  }

  @override
  String toString() {
    final buffer = StringBuffer('GEOMETRYCOLLECTION ');
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
    return '(${geometry.map((e) => e.toString()).join(', ')})';
  }
}
