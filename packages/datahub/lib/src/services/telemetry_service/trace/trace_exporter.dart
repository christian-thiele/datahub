import 'span.dart';

abstract class TraceExporter implements Sink<LocalSpan> {
  Future<void> initialize();
  Future<void> shutdown();
}
