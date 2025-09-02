import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'geometry.dart';

class MultiLineString extends Geometry {
  final List<LineString> lineStrings;

  MultiLineString(int? srid, this.lineStrings, bool hasZ, bool hasM)
      : super(srid, GeometryType.multiLineString, hasZ, hasM);

  factory MultiLineString.read(
      int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return MultiLineString(
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
    bytes.writeUint32(lineStrings.length);
    for (final lineString in lineStrings) {
      bytes.write(lineString.toBytes(byteOrder));
    }
    return bytes.toBytes();
  }

  @override
  String toString() {
    final buffer = StringBuffer('MULTILINESTRING ');
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
    return '(${lineStrings.map((e) => e.toText()).join(',')})';
  }
}
