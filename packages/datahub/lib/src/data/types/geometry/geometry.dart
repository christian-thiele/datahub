import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'geometry_collection.dart';
import 'line_string.dart';
import 'byte_order.dart';
import 'geometry_type.dart';
import 'multi_line_string.dart';
import 'multi_point.dart';
import 'multi_polygon.dart';
import 'point.dart';
import 'polygon.dart';

export 'geometry_collection.dart';
export 'byte_order.dart';
export 'geometry_type.dart';
export 'geometry.dart';
export 'point.dart';
export 'polygon.dart';
export 'multi_point.dart';
export 'multi_line_string.dart';
export 'multi_polygon.dart';
export 'line_string.dart';

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
    final byteOrder = ByteOrder.read(bytes.first);

    final reader = ByteDataReader(endian: byteOrder.endian);
    reader.add(bytes);
    reader.readInt8();

    final typeDef = reader.readUint32();
    final hasZ = typeDef & wkbZ != 0;
    final hasM = typeDef & wkbM != 0;
    final hasSRID = typeDef & wkbSRID != 0;

    final baseType = typeDef & ~wkbZ & ~wkbM & ~wkbSRID;
    final type = GeometryType.read(baseType);

    final srid = hasSRID ? reader.readUint32() : null;

    switch (type) {
      case GeometryType.point:
        return Point.read(srid, reader, hasZ, hasM);
      case GeometryType.lineString:
        return LineString.read(srid, reader, hasZ, hasM);
      case GeometryType.polygon:
        return Polygon.read(srid, reader, hasZ, hasM);
      case GeometryType.multiPoint:
        return MultiPoint.read(srid, reader, hasZ, hasM);
      case GeometryType.multiLineString:
        return MultiLineString.read(srid, reader, hasZ, hasM);
      case GeometryType.multiPolygon:
        return MultiPolygon.read(srid, reader, hasZ, hasM);
      case GeometryType.geometryCollection:
        return GeometryCollection.read(srid, reader, hasZ, hasM);
    }
  }

  static Geometry read(int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    reader.readUint8();
    final typeDef = reader.readUint32();
    final baseType = typeDef & ~wkbZ & ~wkbM & ~wkbSRID;
    final type = GeometryType.read(baseType);

    switch (type) {
      case GeometryType.point:
        return Point.read(srid, reader, hasZ, hasM);
      case GeometryType.lineString:
        return LineString.read(srid, reader, hasZ, hasM);
      case GeometryType.polygon:
        return Polygon.read(srid, reader, hasZ, hasM);
      case GeometryType.multiPoint:
        return MultiPoint.read(srid, reader, hasZ, hasM);
      case GeometryType.multiLineString:
        return MultiLineString.read(srid, reader, hasZ, hasM);
      case GeometryType.multiPolygon:
        return MultiPolygon.read(srid, reader, hasZ, hasM);
      case GeometryType.geometryCollection:
        return GeometryCollection.read(srid, reader, hasZ, hasM);
    }
  }

  Uint8List toEWKB({ByteOrder byteOrder = ByteOrder.wkbNDR}) {
    final builder = ByteDataWriter(endian: byteOrder.endian);
    builder.writeInt8(byteOrder.id);
    final typeInt = type.id |
        (srid != null ? wkbSRID : 0) |
        (hasZ ? wkbZ : 0) |
        (hasM ? wkbM : 0);
    builder.writeInt32(typeInt);
    if (srid != null) {
      builder.writeInt32(srid!);
    }

    builder.write(toBytes(byteOrder));
    return builder.toBytes();
  }

  Uint8List toBytes(ByteOrder byteOrder);
}
