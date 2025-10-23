import 'sample_group.dart';

//TODO docs
abstract class MetricsExporter {
  final Future<List<SampleGroup>> Function() onScrape;

  MetricsExporter({required this.onScrape});

  Future<void> initialize();

  Future<void> shutdown();
}
