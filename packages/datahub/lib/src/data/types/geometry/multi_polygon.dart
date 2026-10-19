import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:buffer/buffer.dart';

import 'geometry.dart';

class const MultiPolygon(
  int? srid,
  final List<Polygon> polygons,
  bool hasZ,
  bool hasM,
) extends Geometry {
  this : super(srid, GeometryType.multiPolygon, hasZ, hasM);

  factory read(int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return MultiPolygon(
      srid,
      List.generate(
        length,
        (i) => Geometry.readMember<Polygon>(srid, reader, hasZ, hasM),
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
      bytes.write(polygon.toWKB(byteOrder));
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

  @override
  bool operator ==(Object other) {
    return other is MultiPolygon &&
        other.srid == srid &&
        other.hasZ == hasZ &&
        other.hasM == hasM &&
        other.polygons.sequenceEquals(polygons);
  }

  @override
  int get hashCode => Object.hashAll([srid, hasZ, hasM, ...polygons]);
}
