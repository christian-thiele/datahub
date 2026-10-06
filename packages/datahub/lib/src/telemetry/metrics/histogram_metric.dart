import 'dart:async';
import 'dart:math';

import 'metric.dart';
import 'metric_sample.dart';
import 'metric_series.dart';
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
/// * histogram
/// * linearHistogram
/// * exponentialHistogram
///
/// This way, the same metric can be injected from different places inside the
/// application.
///
/// Labels are declared either with all of their values ([labels]), which
/// creates a series for every combination upfront, or by name only
/// ([labelNames]), which creates a series once a combination is observed.
/// The latter is meant for labels whose values are bounded, but not known in
/// advance (like routes or status codes), never for unbounded values like
/// ids or paths. Values for labels that were not declared are dropped, see
/// [MetricSeriesSet].
class HistogramMetric extends Metric {
  /// Bucket boundaries for durations in seconds, as recommended by the
  /// semantic conventions (e.g. for `http.server.request.duration`).
  static const defaultDurationBuckets = <num>[
    0.005,
    0.01,
    0.025,
    0.05,
    0.075,
    0.1,
    0.25,
    0.5,
    0.75,
    1,
    2.5,
    5,
    7.5,
    10,
  ];

  final List<num> _boundaries;
  final MetricSeriesSet<_HistogramSeries> _series;

  /// A histogram with the given upper bucket boundaries (ascending).
  HistogramMetric(
    super.name, {
    required List<num> buckets,
    super.help,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
  }) : assert(
         [
           for (var i = 1; i < buckets.length; i++) i,
         ].every((i) => buckets[i - 1] < buckets[i]),
         'Bucket boundaries must be ascending.',
       ),
       _boundaries = List.unmodifiable(buckets),
       _series = MetricSeriesSet(
         name,
         labels: labels,
         labelNames: labelNames,
         create: (labels) => _HistogramSeries(labels, buckets),
       ),
       super(type: MetricType.histogram);

  /// A histogram with [count] buckets of [width], the first one ending at
  /// [start].
  HistogramMetric.linear(
    String name, {
    required num start,
    required num width,
    required int count,
    String? help,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
  }) : this(
         name,
         buckets: List.generate(count, (i) => start + width * i),
         help: help,
         labels: labels,
         labelNames: labelNames,
       );

  /// A histogram with [count] buckets, the first one ending at [start] and
  /// each following one ending at [factor] times the previous end.
  HistogramMetric.exponential(
    String name, {
    required num start,
    required num factor,
    required int count,
    String? help,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
  }) : this(
         name,
         buckets: List.generate(count, (i) => start * pow(factor, i)),
         help: help,
         labels: labels,
         labelNames: labelNames,
       );

  /// The upper boundaries of the buckets.
  List<num> get boundaries => _boundaries;

  /// Observes [value], optionally for the series identified by [labels].
  ///
  /// The [labels] must match one of the label combinations declared when
  /// the metric was defined, or provide a value for each of its label names.
  void observe(num value, [Map<String, String> labels = const {}]) =>
      _series.find(labels)?.observe(value);

  @override
  SampleGroup collect() {
    final now = DateTime.timestamp();
    return SampleGroup(this, [
      for (final series in _series.values) ...[
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
    final watch = Stopwatch()..start();
    try {
      return await delegate();
    } finally {
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
