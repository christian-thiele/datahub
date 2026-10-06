import 'span.dart';

/// Receives the sampled spans of all tracers.
///
/// [onStart] is called when a span starts and [onEnd] when it ends. An
/// exporter may export a span while it is still running, so it is visible
/// even if it never ends (e.g. when the service crashes), but must then
/// export it again once it ended.
abstract class TraceExporter {
  Future<void> initialize();

  void onStart(LocalSpan span);

  void onEnd(LocalSpan span);

  Future<void> shutdown();
}
