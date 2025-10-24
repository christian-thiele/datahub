import 'metric.dart';
import 'metric_sample.dart';

class SampleGroup {
  final Metric metric;
  final List<MetricSample> samples;

  String get name => metric.name;

  SampleGroup(this.metric, this.samples);
}
