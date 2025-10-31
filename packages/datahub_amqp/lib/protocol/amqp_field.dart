
import 'dart:convert';
import 'dart:typed_data';

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
    return AmqpFieldTimestamp(DateTime.fromMillisecondsSinceEpoch(value * 1000));
  }
}

class AmqpFieldFieldTable extends AmqpField {
  @override
  void writeTo(ByteDataWriter writer) {
    //TODO fieldtable
  }
}
