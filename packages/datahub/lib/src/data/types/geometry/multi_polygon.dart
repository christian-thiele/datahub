import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'geometry.dart';

class MultiPolygon extends Geometry {
  final List<Polygon> polygons;

  MultiPolygon(int? srid, this.polygons, bool hasZ, bool hasM)
      : super(srid, GeometryType.multiPolygon, hasZ, hasM);

  factory MultiPolygon.read(
      int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return MultiPolygon(
      srid,
      List.generate(
        length,
        (i) => Polygon.read(srid, reader, hasZ, hasM),
      ),
      hasZ,
      hasM,
    );
  }

  @override
  Uint8List toBytes(ByteOrder byteOrder) {
    final bytes = ByteDataWriter(endian: byteOrder.endian);
    bytes.writeUint32(polygons.length);
    for (final polygon in polygons) {
      bytes.write(polygon.toBytes(byteOrder));
    }
    return bytes.toBytes();
  }

  @override
  String toString() {
    final buffer = StringBuffer('MULTIPOLYGON ');
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
    return '(${polygons.map((e) => e.toText()).join(',')})';
  }
}
