import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:buffer/buffer.dart';
import 'package:datahub/utils.dart';

sealed class AmqpField {
  void writeTo(ByteDataWriter writer);
}

class AmqpFieldBit extends AmqpField {
  final bool value;

  AmqpFieldBit(this.value);

  @override
  void writeTo(ByteDataWriter writer) {
    writer.writeUint8(value ? 1 : 0);
  }

  static AmqpFieldBit readFrom(ByteDataReader reader) {
    return AmqpFieldBit(reader.readUint8() > 0);
  }
}

class AmqpFieldOctet extends AmqpField {
  final int value;

  AmqpFieldOctet(this.value);

  @override
  void writeTo(ByteDataWriter writer) {
    writer.writeUint8(value);
  }

  static AmqpFieldOctet readFrom(ByteDataReader reader) {
    return AmqpFieldOctet(reader.readUint8());
  }
}

class AmqpFieldShortUint extends AmqpField {
  final int value;

  AmqpFieldShortUint(this.value);

  @override
  void writeTo(ByteDataWriter writer) {
    writer.writeUint16(value);
  }

  static AmqpFieldShortUint readFrom(ByteDataReader reader) {
    return AmqpFieldShortUint(reader.readUint16());
  }
}

class AmqpFieldLongUint extends AmqpField {
  final int value;

  AmqpFieldLongUint(this.value);

  @override
  void writeTo(ByteDataWriter writer) {
    writer.writeUint32(value);
  }

  static AmqpFieldLongUint readFrom(ByteDataReader reader) {
    return AmqpFieldLongUint(reader.readUint32());
  }
}

class AmqpFieldLongLongUint extends AmqpField {
  final int value;

  AmqpFieldLongLongUint(this.value);

  @override
  void writeTo(ByteDataWriter writer) {
    writer.writeUint64(value);
  }

  static AmqpFieldLongLongUint readFrom(ByteDataReader reader) {
    return AmqpFieldLongLongUint(reader.readUint64());
  }
}

class AmqpFieldShortString extends AmqpField {
  final String value;

  AmqpFieldShortString(this.value);

  @override
  void writeTo(ByteDataWriter writer) {
    if (value.length > 255) {
      throw ApiError('Cannot marshall short-string with length > 255.');
    }
    writer.writeUint8(value.length);
    writer.write(utf8.encode(value));
  }

  static AmqpFieldShortString readFrom(ByteDataReader reader) {
    final length = reader.readUint8();
    final value = reader.read(length);
    return AmqpFieldShortString(utf8.decode(value));
  }
}

class AmqpFieldLongString extends AmqpField {
  final Uint8List value;

  AmqpFieldLongString(this.value);

  AmqpFieldLongString.fromText(String value) : value = utf8.encode(value);

  @override
  void writeTo(ByteDataWriter writer) {
    if (value.lengthInBytes > 4294967295) {
      throw ApiError('Cannot marshall long-string with length > 4294967295.');
    }
    writer.writeUint32(value.lengthInBytes);
    writer.write(value);
  }

  static AmqpFieldLongString readFrom(ByteDataReader reader) {
    final length = reader.readUint32();
    final value = reader.read(length);
    return AmqpFieldLongString(value);
  }

  String toText() => utf8.decode(value);
}

class AmqpFieldTimestamp extends AmqpField {
  final DateTime value;

  AmqpFieldTimestamp(this.value);

  @override
  void writeTo(ByteDataWriter writer) {
    writer.writeInt64(value.millisecondsSinceEpoch ~/ 1000);
  }

  static AmqpFieldTimestamp readFrom(ByteDataReader reader) {
    final value = reader.readInt64();
    return AmqpFieldTimestamp(
      DateTime.fromMillisecondsSinceEpoch(value * 1000),
    );
  }
}

class AmqpFieldValue extends AmqpField {
  final AmqpField value;

  AmqpFieldValue(this.value);

  static AmqpFieldValue readFrom(ByteDataReader reader) {
    final char = ascii.decode([reader.readUint8()]);
    final value = switch (char) {
      't' => AmqpFieldBit.readFrom(reader),
      'u' => AmqpFieldShortUint.readFrom(reader),
      'i' => AmqpFieldLongUint.readFrom(reader),
      'l' => AmqpFieldLongLongUint.readFrom(reader),
      's' => AmqpFieldShortString.readFrom(reader),
      'S' => AmqpFieldLongString.readFrom(reader),
      'T' => AmqpFieldTimestamp.readFrom(reader),
      'F' => AmqpFieldFieldTable.readFrom(reader),
      _ => throw Exception('Unknown field-value prefix "$char"'),
    };
    return AmqpFieldValue(value);
  }

  @override
  void writeTo(ByteDataWriter writer) {
    switch (value) {
      case AmqpFieldBit():
        writer.write(ascii.encode('t'));
      case AmqpFieldOctet():
        writer.write(ascii.encode('u'));
      case AmqpFieldShortUint():
        writer.write(ascii.encode('u'));
      case AmqpFieldLongUint():
        writer.write(ascii.encode('i'));
      case AmqpFieldLongLongUint():
        writer.write(ascii.encode('l'));
      case AmqpFieldShortString():
        writer.write(ascii.encode('s'));
      case AmqpFieldLongString():
        writer.write(ascii.encode('S'));
      case AmqpFieldTimestamp():
        writer.write(ascii.encode('T'));
      case AmqpFieldFieldTable():
        writer.write(ascii.encode('F'));
      case AmqpFieldValue():
        break;
    }

    value.writeTo(writer);
  }
}

class AmqpFieldFieldTable extends AmqpField {
  final Map<String, AmqpField> values;

  AmqpFieldFieldTable(this.values);

  // TODO this is shit
  AmqpFieldFieldTable.fromValueMap(Map<String, dynamic> map)
    : values = map.map(
        (k, v) => MapEntry(
          k,
          AmqpFieldValue(switch (v) {
            bool value => AmqpFieldBit(value),
            int value => AmqpFieldShortUint(value),
            String value => AmqpFieldLongString.fromText(value),
            _ => throw UnimplementedError(),
          }),
        ),
      );

  @override
  void writeTo(ByteDataWriter writer) {
    writer.writeUint32(values.length);
    for (final (name, value) in values.tuples) {
      AmqpFieldShortString(name).writeTo(writer);
      value.writeTo(writer);
    }
  }

  static AmqpFieldFieldTable readFrom(ByteDataReader reader) {
    final table = <String, AmqpField>{};

    final length = reader.readUint32();
    final end = reader.offsetInBytes + length;

    while (reader.offsetInBytes < end) {
      final name = AmqpFieldShortString.readFrom(reader);
      final value = AmqpFieldValue.readFrom(reader);
      table[name.value] = value;
    }
    return AmqpFieldFieldTable(table);
  }

  dynamic _toValue(AmqpField field) {
    return switch (field) {
      AmqpFieldBit(:final value) => value,
      AmqpFieldOctet(:final value) => value,
      AmqpFieldShortUint(:final value) => value,
      AmqpFieldLongUint(:final value) => value,
      AmqpFieldLongLongUint(:final value) => value,
      AmqpFieldShortString(:final value) => value,
      final AmqpFieldLongString longString => longString.toText(),
      AmqpFieldTimestamp(:final value) => value,
      AmqpFieldValue(:final value) => _toValue(value),
      final AmqpFieldFieldTable table => table.toMap(),
    };
  }

  Map<String, dynamic> toMap() => {
    for (final (k, v) in values.tuples) k: _toValue(v),
  };
}
