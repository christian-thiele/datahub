import 'base_id.dart';

class const TraceId(super.id) extends BaseId {
  static const length = 16;

  this
    : assert(
        id.length == length,
        'Invalid TraceId length. Id must have a length of $length.',
      );

  factory generate() => TraceId(BaseId.generateBytes(length));

  /// Parses the hex representation of a trace id, see [hexId].
  ///
  /// Returns null if [hex] is not a valid trace id.
  static TraceId? tryParse(String? hex) =>
      switch (BaseId.parseHex(hex, length)) {
        final bytes? when bytes.any((b) => b != 0) => TraceId(bytes),
        _ => null,
      };
}
