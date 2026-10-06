import 'base_id.dart';

class SpanId extends BaseId {
  static const length = 8;

  const SpanId(super.id)
    : assert(
        id.length == length,
        'Invalid SpanId length. Id must have a length of $length.',
      );

  factory SpanId.generate() => SpanId(BaseId.generateBytes(length));

  /// Parses the hex representation of a span id, see [hexId].
  ///
  /// Returns null if [hex] is not a valid span id.
  static SpanId? tryParse(String? hex) =>
      switch (BaseId.parseHex(hex, length)) {
        final bytes? when bytes.any((b) => b != 0) => SpanId(bytes),
        _ => null,
      };
}
