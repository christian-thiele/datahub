import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:buffer/buffer.dart';

import 'geometry.dart';

class const MultiPoint(
  int? srid,
  final List<Point> points,
  bool hasZ,
  bool hasM,
) extends Geometry {
  this : super(srid, GeometryType.multiPoint, hasZ, hasM);

  factory read(int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return MultiPoint(
      srid,
      List.generate(
        length,
        (i) => Geometry.readMember<Point>(srid, reader, hasZ, hasM),
      ),
      hasZ,
      hasM,
    );
  }

  @override
  Uint8List toBytes(ByteOrder byteOrder) {
    final bytes = ByteDataWriter(endian: byteOrder.endian);
    bytes.writeUint32(points.length);
    for (final point in points) {
      bytes.write(point.toWKB(byteOrder));
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

  @override
  bool operator ==(Object other) {
    return other is MultiPoint &&
        other.srid == srid &&
        other.hasZ == hasZ &&
        other.hasM == hasM &&
        other.points.sequenceEquals(points);
  }

  @override
  int get hashCode => Object.hashAll([srid, hasZ, hasM, ...points]);
}
