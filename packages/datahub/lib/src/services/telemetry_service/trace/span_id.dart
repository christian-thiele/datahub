
import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';

import 'base_id.dart';

class SpanId extends BaseId {
  static const length = 8;

  const SpanId(super.id)
    : assert(
        id.length == length,
        'Invalid SpanId length. Id must have a length of $length.',
      );

  factory SpanId.generate() {
    return SpanId(randomBytes(length).toList().asUint8List());
  }
}
