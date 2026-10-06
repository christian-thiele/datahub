import 'dart:math';

import 'metric.dart';
import 'metric_sample.dart';
import 'metric_series.dart';
import 'sample_group.dart';

/// A counter metric for use with [TelemetryService].
///
/// A counter is a cumulative metric that represents a single monotonically
/// increasing counter whose value can only increase or be reset to zero on
/// restart. For example, a counter can represent the number of
/// requests served, tasks completed, or errors. Counter names end with
/// `_total`.
///
/// Best practice for creating metric instances is by using the metric
/// definition methods on [TelemetryService]:
///  - counter
///  - gauge
///  - histogram
///  - linearHistogram
///  - exponentialHistogram
///
/// This way, the same metric can be injected from different places inside the
/// application.
///
/// Labels are declared either with all of their values ([labels]) or by name
/// only ([labelNames]), see [MetricSeriesSet]. Values for labels that were
/// not declared are dropped.
///
/// For exposing a value that can decrease, use a [GaugeMetric] instead.
class CounterMetric extends Metric {
  final MetricSeriesSet<_CounterSeries> _series;

  CounterMetric(
    super.name, {
    super.help,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
  }) : _series = MetricSeriesSet(
         name,
         labels: labels,
         labelNames: labelNames,
         create: _CounterSeries.new,
       ),
       super(type: MetricType.counter);

  @override
  SampleGroup collect() {
    final now = DateTime.timestamp();
    return SampleGroup(this, [
      for (final series in _series.values)
        MetricSample(name, series.labels, series._value, now),
    ]);
  }

  /// Increases the counter by 1.
  void inc([Map<String, String> labels = const {}]) =>
      _series.find(labels)?.inc();

  /// Increases the counter by [val]. Negative values are ignored.
  void incBy(num val, [Map<String, String> labels = const {}]) =>
      _series.find(labels)?.incBy(val);
}

class _CounterSeries {
  final Map<String, String> labels;
  num _value = 0;

  _CounterSeries(this.labels);

  void inc() => ++_value;

  void incBy(num val) => _value += max(0, val);
}
