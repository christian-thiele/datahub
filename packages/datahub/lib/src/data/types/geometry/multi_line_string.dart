import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:buffer/buffer.dart';

import 'geometry.dart';

class const MultiLineString(
  int? srid,
  final List<LineString> lineStrings,
  bool hasZ,
  bool hasM,
) extends Geometry {
  this : super(srid, GeometryType.multiLineString, hasZ, hasM);

  factory read(int? srid, ByteDataReader reader, bool hasZ, bool hasM) {
    final length = reader.readUint32();
    return MultiLineString(
      srid,
      List.generate(
        length,
        (i) => Geometry.readMember<LineString>(srid, reader, hasZ, hasM),
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
      bytes.write(lineString.toWKB(byteOrder));
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

  @override
  bool operator ==(Object other) {
    return other is MultiLineString &&
        other.srid == srid &&
        other.hasZ == hasZ &&
        other.hasM == hasM &&
        other.lineStrings.sequenceEquals(lineStrings);
  }

  @override
  int get hashCode => Object.hashAll([srid, hasZ, hasM, ...lineStrings]);
}
