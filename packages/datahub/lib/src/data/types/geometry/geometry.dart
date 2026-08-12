import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'byte_order.dart';
import 'geometry_collection.dart';
import 'geometry_type.dart';
import 'line_string.dart';
import 'multi_line_string.dart';
import 'multi_point.dart';
import 'multi_polygon.dart';
import 'point.dart';
import 'polygon.dart';

export 'byte_order.dart';
export 'geometry.dart';
export 'geometry_collection.dart';
export 'geometry_type.dart';
export 'line_string.dart';
export 'multi_line_string.dart';
export 'multi_point.dart';
export 'multi_polygon.dart';
export 'point.dart';
export 'polygon.dart';

const wkbZ = 0x80000000;
const wkbM = 0x40000000;
const wkbSRID = 0x20000000;

/// SRId of the WGS 84 (latitude / longitude) spacial reference system.
const wgs84 = 4326;

abstract class Geometry {
  final int? srid;
  final GeometryType type;
  final bool hasZ;
  final bool hasM;

  const Geometry(this.srid, this.type, this.hasZ, this.hasM);

  static Geometry parseEWKB(Uint8List bytes) {
    final reader = ByteDataReader(endian: ByteOrder.read(bytes.first).endian);
    reader.add(bytes);
    return read(null, reader, false, false);
  }

  /// Reads a geometry including the byte order and type it starts with.
  ///
  /// This is how a geometry is encoded on its own as well as inside a multi
  /// geometry or a collection. [srid], [hasZ] and [hasM] of the enclosing
  /// geometry apply to a member that does not declare them itself.
  static Geometry read(int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final byteOrder = ByteOrder.read(reader.readUint8());
    if (byteOrder.endian != reader.endian) {
      // Members are allowed to bring their own byte order, but no writer makes
      // use of that and the reader is fixed to the one of the outermost
      // geometry, so reading on would quietly produce garbage.
      throw FormatException(
        'Geometry member is ${byteOrder.name} encoded, which differs from the '
        'byte order of the geometry containing it.',
      );
    }

    final typeDef = reader.readUint32();
    final type = GeometryType.read(typeDef & ~wkbZ & ~wkbM & ~wkbSRID);

    return _readBody(
      type,
      typeDef & wkbSRID != 0 ? reader.readUint32() : srid,
      reader,
      hasZ || typeDef & wkbZ != 0,
      hasM || typeDef & wkbM != 0,
    );
  }

  /// Reads a member of a multi geometry, which has to be a [T].
  static T readMember<T extends Geometry>(
    int? srid,
    ByteDataReader reader,
    bool hasZ,
    bool hasM,
  ) {
    final member = read(srid, reader, hasZ, hasM);
    if (member is! T) {
      throw FormatException(
        'Expected a $T inside the multi geometry, got a ${member.type.name}.',
      );
    }

    return member;
  }

  /// Reads the coordinates that follow the header of a geometry of [type].
  static Geometry _readBody(
    GeometryType type,
    int? srid,
    ByteDataReader reader,
    bool hasZ,
    bool hasM,
  ) => switch (type) {
    GeometryType.point => Point.read(srid, reader, hasZ, hasM),
    GeometryType.lineString => LineString.read(srid, reader, hasZ, hasM),
    GeometryType.polygon => Polygon.read(srid, reader, hasZ, hasM),
    GeometryType.multiPoint => MultiPoint.read(srid, reader, hasZ, hasM),
    GeometryType.multiLineString => MultiLineString.read(
      srid,
      reader,
      hasZ,
      hasM,
    ),
    GeometryType.multiPolygon => MultiPolygon.read(srid, reader, hasZ, hasM),
    GeometryType.geometryCollection => GeometryCollection.read(
      srid,
      reader,
      hasZ,
      hasM,
    ),
  };

  /// The extended WKB representation, which adds the [srid] to the type.
  Uint8List toEWKB({ByteOrder byteOrder = ByteOrder.wkbNDR}) =>
      _write(byteOrder, srid);

  /// The plain WKB representation, which is how this geometry is written as a
  /// member of a multi geometry or a collection: only the geometry containing
  /// it carries an SRID.
  Uint8List toWKB(ByteOrder byteOrder) => _write(byteOrder, null);

  Uint8List _write(ByteOrder byteOrder, int? srid) {
    final builder = ByteDataWriter(endian: byteOrder.endian);
    builder.writeUint8(byteOrder.id);
    builder.writeUint32(
      type.id |
          (srid != null ? wkbSRID : 0) |
          (hasZ ? wkbZ : 0) |
          (hasM ? wkbM : 0),
    );

    if (srid != null) {
      builder.writeUint32(srid);
    }

    builder.write(toBytes(byteOrder));
    return builder.toBytes();
  }

  Uint8List toBytes(ByteOrder byteOrder);
}
