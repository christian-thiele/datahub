import 'sample_group.dart';

/// Exposes the metrics returned by [onScrape], e.g. [PrometheusExporter].
abstract class MetricsExporter {
  final Future<List<SampleGroup>> Function() onScrape;

  MetricsExporter({required this.onScrape});

  Future<void> initialize();

  Future<void> shutdown();
}
