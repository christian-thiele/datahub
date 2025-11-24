import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:datahub_amqp/protocol/amqp_field.dart';

List<AmqpField> parseArguments(
  Uint8List data,
  List<AmqpField Function(ByteDataReader)> parsers,
) {
  final reader = ByteDataReader();
  reader.add(data);
  final values = <AmqpField>[];
  for (final parser in parsers) {
    values.add(parser(reader));
  }
  return values;
}
