import 'dart:async';
import 'dart:math';

import 'metric.dart';
import 'metric_sample.dart';
import 'sample_group.dart';

/// A histogram metric for use with [TelemetryService].
///
/// A histogram samples observations (usually things like request durations or
/// response sizes) and counts them in configurable buckets.
/// It also provides a sum of all observed values.
///
/// A histogram with a base metric name of <basename> exposes multiple time
/// series during a scrape:
///
/// * cumulative counters for the observation buckets, exposed as
///   <basename>_bucket{le="<upper inclusive bound>"}
/// * the total sum of all observed values, exposed as <basename>_sum
/// * the count of events that have been observed, exposed as <basename>_count
///   (identical to <basename>_bucket{le="+Inf"} above)
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
  final _buckets = <_Bucket>[];
  num _count = 0;
  num _sum = 0;

  HistogramMetric.linear(
    super.name, {
    required num start,
    required num width,
    required int count,
    super.help,
  }) : super(type: MetricType.histogram) {
    _buckets.addAll(
      Iterable.generate(count, (i) => _Bucket(start + (width / count) * i)),
    );
  }

  HistogramMetric.exponential(
    super.name, {
    required num start,
    required num factor,
    required int count,
    super.help,
  }) : super(type: MetricType.histogram) {
    _buckets.addAll(
      Iterable.generate(count, (i) => _Bucket(start * pow(factor, i))),
    );
  }

  void observe(num value) {
    _count++;
    _sum += value;
    for (final bucket in _buckets.reversed) {
      if (value <= bucket.boundary) {
        bucket.value++;
      } else {
        return;
      }
    }
  }

  @override
  SampleGroup collect() {
    final now = DateTime.timestamp();
    return SampleGroup(this, [
      ..._buckets.map(
        (b) => MetricSample(
          '${name}_bucket',
          {'le': b.boundary.toString()},
          b.value,
          now,
        ),
      ),
      MetricSample('${name}_bucket', {'le': '+Inf'}, _count, now),
      MetricSample('${name}_sum', {}, _sum, now),
      MetricSample('${name}_count', {}, _count, now),
    ]);
  }

  void observeDuration(Duration duration) {
    observe(duration.inMicroseconds / 1000000);
  }

  FutureOr<T> measureDuration<T>(FutureOr<T> Function() delegate) async {
    final watch = Stopwatch();
    watch.start();
    try {
      return await delegate();
    } finally {
      watch.stop();
      observeDuration(watch.elapsed);
    }
  }
}

class _Bucket {
  final num boundary;
  num value = 0;

  _Bucket(this.boundary);
}
