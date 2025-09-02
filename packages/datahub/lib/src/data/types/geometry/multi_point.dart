import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'geometry.dart';

class MultiPoint extends Geometry {
  final List<Point> points;

  MultiPoint(int? srid, this.points, bool hasZ, bool hasM)
      : super(srid, GeometryType.multiPoint, hasZ, hasM);

  factory MultiPoint.read(
      int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return MultiPoint(
      srid,
      List.generate(length, (i) => Point.read(srid, reader, hasZ, hasM)),
      hasZ,
      hasM,
    );
  }

  @override
  Uint8List toBytes(ByteOrder byteOrder) {
    final bytes = ByteDataWriter(endian: byteOrder.endian);
    bytes.writeUint32(points.length);
    for (final point in points) {
      bytes.write(point.toBytes(byteOrder));
    }
    return bytes.toBytes();
  }

  @override
  String toString() {
    final buffer = StringBuffer('MULTIPOINT ');
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
    return '(${points.map((e) => e.toText()).join(',')})';
  }
}
