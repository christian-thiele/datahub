import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:buffer/buffer.dart';

import 'geometry.dart';

class const GeometryCollection(
  int? srid,
  final List<Geometry> geometry,
  bool hasZ,
  bool hasM,
) extends Geometry {
  this : super(srid, GeometryType.geometryCollection, hasZ, hasM);

  const new empty({int? srid, bool hasZ = false, bool hasM = false})
    : this(srid, const <Geometry>[], hasZ, hasM);

  factory read(int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
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
    for (final member in geometry) {
      bytes.write(member.toWKB(byteOrder));
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

  @override
  bool operator ==(Object other) {
    return other is GeometryCollection &&
        other.srid == srid &&
        other.hasZ == hasZ &&
        other.hasM == hasM &&
        other.geometry.sequenceEquals(geometry);
  }

  @override
  int get hashCode => Object.hashAll([srid, hasZ, hasM, ...geometry]);
}
