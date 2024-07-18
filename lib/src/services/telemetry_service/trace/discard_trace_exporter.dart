import 'span.dart';
import 'trace_exporter.dart';

/// [TraceExporter] implementation that discards traces.
///
/// This is used as fallback.
class DiscardTraceExporter extends TraceExporter {
  @override
  void add(Span data) {
    // discard
  }

  @override
  void close() {
    // ignore
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> shutdown() async {}
}
