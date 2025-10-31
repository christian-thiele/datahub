import 'dart:typed_data';
import 'package:buffer/buffer.dart';

import 'amqp_field.dart';
import 'constants.dart';

enum PropertyType {
  shortString,
  longString,
  table,
  octet,
  timestamp,
}

enum BasicProperty {
  contentType(0, PropertyType.shortString),
  contentEncoding(1, PropertyType.shortString),
  headers(2, PropertyType.table),
  deliveryMode(3, PropertyType.octet),
  priority(4, PropertyType.octet),
  correlationId(5, PropertyType.shortString),
  replyTo(6, PropertyType.shortString),
  expiration(7, PropertyType.shortString),
  messageId(8, PropertyType.shortString),
  timestamp(9, PropertyType.timestamp),
  type(10, PropertyType.shortString),
  userId(11, PropertyType.shortString),
  appId(12, PropertyType.shortString);

  final int position;
  final PropertyType propertyType;

  const BasicProperty(this.position, this.propertyType);
}

sealed class AmqpFrame {
  final int channelId;

  int get type;

  const AmqpFrame({required this.channelId});

  Uint8List buildPayload();

  Uint8List pack() {
    final payload = buildPayload();
    final writer = ByteDataWriter(
      bufferLength: payload.lengthInBytes + 8,
      endian: Endian.big,
    );
    writer.writeUint8(type);
    writer.writeUint16(channelId);
    writer.writeUint32(payload.lengthInBytes);
    writer.write(payload);
    writer.writeUint8(frameEnd);
    return writer.toBytes();
  }
}

class MethodFrame extends AmqpFrame {
  final int classId;
  final int methodId;
  Uint8List arguments;

  @override
  final int type = frameMethod;

  MethodFrame({
    required super.channelId,
    required this.classId,
    required this.methodId,
    required this.arguments,
  });

  static MethodFrame parseBody(int channelId, Uint8List body) {
    final reader = ByteDataReader(endian: Endian.big);
    reader.add(body);

    return MethodFrame(
      channelId: channelId,
      classId: reader.readUint16(),
      methodId: reader.readUint16(),
      arguments: reader.read(reader.remainingLength),
    );
  }

  @override
  Uint8List buildPayload() {
    final writer = ByteDataWriter(
      bufferLength: arguments.lengthInBytes + 4,
      endian: Endian.big,
    );
    writer.writeUint16(classId);
    writer.writeUint16(methodId);
    writer.write(arguments);
    return writer.toBytes();
  }
}

class HeaderFrame extends AmqpFrame {
  final int classId;
  final int bodySize;
  final Map<BasicProperty, AmqpField> properties;

  @override
  final int type = frameHeader;

  HeaderFrame({
    required super.channelId,
    required this.classId,
    required this.bodySize,
    required this.properties,
  });

  static HeaderFrame parseBody(int channelId, Uint8List body) {
    final reader = ByteDataReader(endian: Endian.big);
    reader.add(body);

    final classId = reader.readUint16();
    reader.readUint16();
    final bodySize = reader.readUint64();
    final propertyFlags = <int>[];
    while (propertyFlags.isEmpty || propertyFlags.last & 1 == 1) {
      propertyFlags.add(reader.readUint16());
    }

    // we only know 13 flags so first short should contain everything
    final flags = propertyFlags.first;
    final properties = <BasicProperty, AmqpField>{};
    for (final property in BasicProperty.values) {
      if ((flags >> (15 - property.position)) & 1 == 1) {
        properties[property] = switch(property.propertyType) {
          PropertyType.shortString => AmqpFieldShortString.readFrom(reader),
          PropertyType.longString => AmqpFieldLongString.readFrom(reader),
          PropertyType.table => AmqpFieldFieldTable.readFrom(reader),
          PropertyType.octet => AmqpFieldOctet.readFrom(reader),
          PropertyType.timestamp => AmqpFieldTimestamp.readFrom(reader),
        };
      }
    }

    return HeaderFrame(
      channelId: channelId,
      classId: classId,
      bodySize: bodySize,
      properties: properties,
    );
  }

  @override
  Uint8List buildPayload() {
    final writer = ByteDataWriter(endian: Endian.big);
    writer.writeUint16(classId);
    writer.writeUint16(0);
    writer.writeUint64(bodySize);

    // we only know 13 properties (fitting into 1 short) so there is no need to
    // handle multi-short flags here
    var propertyFlag = 0;
    for (final property in BasicProperty.values) {
      if (properties.containsKey(property)) {
        propertyFlag += (1 << (15 - property.position));
      }
    }

    writer.writeUint16(propertyFlag);

    for (final property in BasicProperty.values) {
      if (properties[property] case final field?) {
        field.writeTo(writer);
      }
    }

    return writer.toBytes();
  }
}

class HeartbeatFrame extends AmqpFrame {
  @override
  final int type = frameHeartbeat;

  const HeartbeatFrame() : super(channelId: 0);

  @override
  Uint8List buildPayload() => Uint8List(0);
}
