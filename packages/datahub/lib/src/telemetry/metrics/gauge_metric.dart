import 'dart:async';

import 'metric.dart';
import 'metric_sample.dart';
import 'metric_series.dart';
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
class GaugeMetric extends Metric {
  final MetricSeriesSet<GaugeSeries> _series;

  GaugeMetric(
    super.name, {
    super.help,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
  }) : _series = MetricSeriesSet(
         name,
         labels: labels,
         labelNames: labelNames,
         create: GaugeSeries.new,
       ),
       super(type: MetricType.gauge);

  @override
  SampleGroup collect() {
    final now = DateTime.timestamp();
    return SampleGroup(this, [
      for (final series in _series.values)
        MetricSample(name, series.labels, series._value, now),
    ]);
  }

  void inc([Map<String, String> labels = const {}]) =>
      _series.find(labels)?.inc();

  void dec([Map<String, String> labels = const {}]) =>
      _series.find(labels)?.dec();

  void incBy(num val, [Map<String, String> labels = const {}]) =>
      _series.find(labels)?.incBy(val);

  void set(num val, [Map<String, String> labels = const {}]) =>
      _series.find(labels)?.set(val);

  void setDuration(Duration val, [Map<String, String> labels = const {}]) =>
      _series.find(labels)?.setDuration(val);

  void setTimestamp(DateTime val, [Map<String, String> labels = const {}]) =>
      _series.find(labels)?.setTimestamp(val);

  /// Runs [delegate] and sets the gauge to its duration in seconds.
  ///
  /// If [delegate] returns a [Future], the duration is set once it
  /// completes.
  T measureDuration<T>(
    T Function() delegate, [
    Map<String, String> labels = const {},
  ]) => switch (_series.find(labels)) {
    final series? => series.measureDuration(delegate),
    null => delegate(),
  };

  Future<T> measureDurationAsync<T>(
    Future<T> Function() delegate, [
    Map<String, String> labels = const {},
  ]) => switch (_series.find(labels)) {
    final series? => series.measureDurationAsync(delegate),
    null => delegate(),
  };
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
    final watch = Stopwatch()..start();
    final T result;
    try {
      result = delegate();
    } catch (_) {
      setDuration(watch.elapsed);
      rethrow;
    }

    if (result is Future) {
      unawaited(
        result.then(
          (_) => setDuration(watch.elapsed),
          onError: (_) => setDuration(watch.elapsed),
        ),
      );
    } else {
      setDuration(watch.elapsed);
    }
    return result;
  }

  Future<T> measureDurationAsync<T>(Future<T> Function() delegate) async {
    final watch = Stopwatch()..start();
    try {
      return await delegate();
    } finally {
      setDuration(watch.elapsed);
    }
  }
}
