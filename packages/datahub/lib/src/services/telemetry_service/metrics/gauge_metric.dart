import 'dart:async';

import 'package:datahub/utils.dart';

import 'metric.dart';
import 'metric_sample.dart';
import 'sample_group.dart';

/// A gauge metric for use with [TelemetryService].
///
/// A gauge is a metric that represents a single numerical value that can
/// arbitrarily go up and down. Gauges are typically used for measured values
/// like temperatures or current memory usage, but also "counts" that can go up
/// and down, like the number of concurrent requests.
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
class GaugeMetric extends Metric {
  final _series = <GaugeSeries>[];

  GaugeMetric(super.name, {super.help, Map<String, List<String>>? labels})
    : super(type: MetricType.counter) {
    if (labels != null) {
      final combinations = everyCombination(
        labels.entries.map(
          (e) => e.value.map((value) => MapEntry(e.key, value)),
        ),
      );
      for (final combination in combinations) {
        _series.add(GaugeSeries(Map.fromEntries(combination)));
      }
    } else {
      _series.add(GaugeSeries(const {}));
    }
  }

  @override
  SampleGroup collect() {
    return SampleGroup(this, [
      for (final series in _series)
        MetricSample(name, series.labels, series._value, DateTime.timestamp()),
    ]);
  }

  GaugeSeries _findSeries(Map<String, String> labels) {
    return _series.firstWhere(
      (s) => s.labels.entriesEqual(labels),
      orElse: () =>
          throw ApiError('No metric series matches given label combination.'),
    );
  }

  void inc([Map<String, String> labels = const {}]) =>
      _findSeries(labels).inc();

  void dec([Map<String, String> labels = const {}]) =>
      _findSeries(labels).dec();

  void incBy(num val, [Map<String, String> labels = const {}]) =>
      _findSeries(labels).incBy(val);

  void set(num val, [Map<String, String> labels = const {}]) =>
      _findSeries(labels).set(val);

  void setDuration(Duration val, [Map<String, String> labels = const {}]) =>
      _findSeries(labels).setDuration(val);

  void setTimestamp(DateTime val, [Map<String, String> labels = const {}]) =>
      _findSeries(labels).setTimestamp(val);

  T measureDuration<T>(
    T Function() delegate, [
    Map<String, String> labels = const {},
  ]) => _findSeries(labels).measureDuration(delegate);

  Future<T> measureDurationAsync<T>(
    Future<T> Function() delegate, [
    Map<String, String> labels = const {},
  ]) => _findSeries(labels).measureDurationAsync(delegate);
}

class GaugeSeries {
  final Map<String, String> labels;
  num _value = 0;

  GaugeSeries(this.labels);

  void inc() => ++_value;

  void dec() => --_value;

  void incBy(num val) => _value += val;

  void set(num val) => _value = val;

  void setDuration(Duration val) => _value = val.inMicroseconds / 1000000;

  void setTimestamp(DateTime val) =>
      _value = val.microsecondsSinceEpoch / 1000000;

  T measureDuration<T>(T Function() delegate) {
    final watch = Stopwatch();
    watch.start();
    try {
      return delegate();
    } finally {
      watch.stop();
      setDuration(watch.elapsed);
    }
  }

  Future<T> measureDurationAsync<T>(Future<T> Function() delegate) async {
    final watch = Stopwatch();
    watch.start();
    try {
      return delegate();
    } finally {
      watch.stop();
      setDuration(watch.elapsed);
    }
  }
}
