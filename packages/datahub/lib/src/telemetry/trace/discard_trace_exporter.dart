import 'span.dart';
import 'trace_exporter.dart';

/// [TraceExporter] implementation that discards traces.
///
/// This is used as fallback.
class DiscardTraceExporter extends TraceExporter {
  @override
  void onStart(LocalSpan span) {
    // discard
  }

  @override
  void onEnd(LocalSpan span) {
    // discard
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> shutdown() async {}
}
