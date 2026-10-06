import '../span_id.dart';
import '../trace_id.dart';
import 'span.dart';

/// Propagation of spans across processes according to
/// [W3C Trace Context](https://www.w3.org/TR/trace-context/) (`traceparent`
/// header).
abstract final class TraceContext {
  static const traceparentHeader = 'traceparent';

  static final _traceparent = RegExp(
    r'^([0-9a-f]{2})-([0-9a-f]{32})-([0-9a-f]{16})-([0-9a-f]{2})(-.*)?$',
  );

  /// Parses a `traceparent` header value into a remote [Span].
  ///
  /// Returns null if [traceparent] is null or invalid.
  static Span? parse(String? traceparent) {
    final match = _traceparent.firstMatch(traceparent?.trim() ?? '');
    if (match == null) {
      return null;
    }

    final version = match[1]!;
    // version 00 has no further fields, ff is invalid
    if (version == 'ff' || (version == '00' && match[5] != null)) {
      return null;
    }

    final traceId = TraceId.tryParse(match[2]);
    final spanId = SpanId.tryParse(match[3]);
    if (traceId == null || spanId == null) {
      return null;
    }

    return Span.remote(
      traceId: traceId,
      spanId: spanId,
      traceFlags: int.parse(match[4]!, radix: 16),
    );
  }

  /// Reads the `traceparent` header (case-insensitively) from [headers].
  static Span? fromHeaders(Map<String, List<String>> headers) {
    for (final MapEntry(:key, :value) in headers.entries) {
      if (key.toLowerCase() == traceparentHeader && value.length == 1) {
        return parse(value.single);
      }
    }
    return null;
  }

  /// The `traceparent` header value for [span].
  static String format(Span span) =>
      '00-${span.traceId.hexId}-${span.spanId.hexId}-'
      '${(span.traceFlags & 0xff).toRadixString(16).padLeft(2, '0')}';
}
