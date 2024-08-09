import 'span.dart';

abstract class TraceExporter implements Sink<Span> {
  Future<void> initialize();
  Future<void> shutdown();
}
