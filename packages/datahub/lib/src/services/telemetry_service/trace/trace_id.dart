import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';

import 'base_id.dart';

class TraceId extends BaseId {
  static const length = 16;

  const TraceId(Uint8List id)
    : assert(
        id.length == length,
        'Invalid TraceId length. Id must have a length of $length.',
      ),
      super(id);

  factory TraceId.generate() {
    return TraceId(randomBytes(length).toList().asUint8List());
  }
}
