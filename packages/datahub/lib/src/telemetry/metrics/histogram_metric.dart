import 'dart:async';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';

import 'metric.dart';
import 'metric_sample.dart';
import 'sample_group.dart';

/// A histogram metric for use with [TelemetryService].
///
/// A histogram samples observations (usually things like request durations or
/// response sizes) and counts them in configurable buckets.
/// It also provides a sum of all observed values.
///
/// A histogram with a base metric name of &lt;basename&gt; exposes multiple time
/// series during a scrape:
///
/// * cumulative counters for the observation buckets, exposed as
///   &lt;basename&gt;_bucket{le="&lt;upper inclusive bound&gt;"}
/// * the total sum of all observed values, exposed as &lt;basename&gt;_sum
/// * the count of events that have been observed, exposed as &lt;basename&gt;_count
///   (identical to &lt;basename&gt;_bucket{le="+Inf"} above)
///
/// Best practice for creating metric instances is by using the metric
/// definition methods on [TelemetryService]:
/// * counter
/// * gauge
/// * linearHistogram
/// * exponentialHistogram
///
/// This way, the same metric can be injected from different places inside the
/// application.
/// Metrics can be instantiated anywhere and registered at the
/// [TelemetryService] either through the [ServiceResolver] by invoking
/// the [register] method.
class HistogramMetric extends Metric {
  final List<num> _boundaries;
  final _series = <_HistogramSeries>[];

  HistogramMetric.linear(
    super.name, {
    required num start,
    required num width,
    required int count,
    super.help,
    Map<String, List<String>>? labels,
  }) : _boundaries = List.generate(count, (i) => start + (width / count) * i),
       super(type: MetricType.histogram) {
    _createSeries(labels);
  }

  HistogramMetric.exponential(
    super.name, {
    required num start,
    required num factor,
    required int count,
    super.help,
    Map<String, List<String>>? labels,
  }) : _boundaries = List.generate(count, (i) => start * pow(factor, i)),
       super(type: MetricType.histogram) {
    _createSeries(labels);
  }

  void _createSeries(Map<String, List<String>>? labels) {
    if (labels != null && labels.isNotEmpty) {
      final combinations = cartesianProduct(
        labels.entries.map(
          (e) => e.value.map((value) => MapEntry(e.key, value)),
        ),
      );
      for (final combination in combinations) {
        _series.add(
          _HistogramSeries(Map.fromEntries(combination), _boundaries),
        );
      }
    } else {
      _series.add(_HistogramSeries(const {}, _boundaries));
    }
  }

  _HistogramSeries _findSeries(Map<String, String> labels) {
    return _series.firstWhere(
      (s) => s.labels.entriesEqual(labels),
      orElse: () =>
          throw ApiError('No metric series matches given label combination.'),
    );
  }

  /// Observes [value], optionally for the series identified by [labels].
  ///
  /// The [labels] must match one of the label combinations declared when
  /// the metric was defined.
  void observe(num value, [Map<String, String> labels = const {}]) =>
      _findSeries(labels).observe(value);

  @override
  SampleGroup collect() {
    final now = DateTime.timestamp();
    return SampleGroup(this, [
      for (final series in _series) ...[
        for (final b in series.buckets)
          MetricSample(
            '${name}_bucket',
            {...series.labels, 'le': b.boundary.toString()},
            b.value,
            now,
          ),
        MetricSample(
          '${name}_bucket',
          {...series.labels, 'le': '+Inf'},
          series.count,
          now,
        ),
        MetricSample('${name}_sum', series.labels, series.sum, now),
        MetricSample('${name}_count', series.labels, series.count, now),
      ],
    ]);
  }

  void observeDuration(
    Duration duration, [
    Map<String, String> labels = const {},
  ]) {
    observe(duration.inMicroseconds / 1000000, labels);
  }

  FutureOr<T> measureDuration<T>(
    FutureOr<T> Function() delegate, [
    Map<String, String> labels = const {},
  ]) async {
    final watch = Stopwatch();
    watch.start();
    try {
      return await delegate();
    } finally {
      watch.stop();
      observeDuration(watch.elapsed, labels);
    }
  }
}

class _HistogramSeries {
  final Map<String, String> labels;
  final List<_Bucket> buckets;
  num count = 0;
  num sum = 0;

  _HistogramSeries(this.labels, List<num> boundaries)
    : buckets = [for (final b in boundaries) _Bucket(b)];

  void observe(num value) {
    count++;
    sum += value;
    for (final bucket in buckets.reversed) {
      if (value <= bucket.boundary) {
        bucket.value++;
      } else {
        return;
      }
    }
  }
}

class _Bucket {
  final num boundary;
  num value = 0;

  _Bucket(this.boundary);
}
