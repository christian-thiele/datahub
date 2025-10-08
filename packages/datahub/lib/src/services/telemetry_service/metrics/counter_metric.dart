import 'dart:math';

import 'package:datahub/utils.dart';

import 'metric.dart';
import 'metric_sample.dart';
import 'sample_group.dart';

/// A counter metric for use with [TelemetryService].
///
/// A counter is a cumulative metric that represents a single monotonically
/// increasing counter whose value can only increase or be reset to zero on
/// restart. For example, a counter can represent the number of
/// requests served, tasks completed, or errors.
///
/// Best practice for creating metric instances is by using the metric
/// definition methods on [TelemetryService]:
///  - counter
///  - gauge
///  - linearHistogram
///  - exponentialHistogram
///
/// This way, the same metric can be injected from different places inside the
/// application.
/// Metrics can be instantiated anywhere and registered at the
/// [TelemetryService] either through the [ServiceResolver] by invoking
/// the [register] method.
///
/// For exposing a value that can decrease, use a [GaugeMetric] instead.
class CounterMetric extends Metric {
  final _series = <_CounterSeries>[];

  CounterMetric(super.name, {super.help, Map<String, List<String>>? labels})
    : super(type: MetricType.counter) {
    if (labels != null) {
      final combinations = everyCombination(
        labels.entries.map(
          (e) => e.value.map((value) => MapEntry(e.key, value)),
        ),
      );
      for (final combination in combinations) {
        _series.add(_CounterSeries(Map.fromEntries(combination)));
      }
    } else {
      _series.add(_CounterSeries(const {}));
    }
  }

  @override
  SampleGroup collect() {
    return SampleGroup(this, [
      for (final series in _series)
        MetricSample(name, series.labels, series._value, DateTime.timestamp()),
    ]);
  }

  _CounterSeries _findSeries(Map<String, String> labels) {
    return _series.firstWhere(
      (s) => s.labels.entriesEqual(labels),
      orElse: () =>
          throw ApiError('No metric series matches given label combination.'),
    );
  }

  /// Increases the counter by 1.
  void inc([Map<String, String> labels = const {}]) {
    _findSeries(labels).inc();
  }

  /// Increases the counter by [val].
  void incBy(num val, [Map<String, String> labels = const {}]) =>
      _findSeries(labels).incBy(val);
}

class _CounterSeries {
  final Map<String, String> labels;
  num _value = 0;

  _CounterSeries(this.labels);

  void inc() => ++_value;

  void incBy(num val) => _value += max(0, val);
}
