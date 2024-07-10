import 'dart:async';
import 'dart:math';

import 'metric.dart';
import 'metric_sample.dart';

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
        Iterable.generate(count, (i) => _Bucket(start + (width / count) * i)));
  }

  HistogramMetric.exponential(
    super.name, {
    required num start,
    required num factor,
    required int count,
    super.help,
  }) : super(type: MetricType.histogram) {
    _buckets.addAll(
        Iterable.generate(count, (i) => _Bucket(start * pow(factor, i))));
  }

  void observe(num value) {
    _count++;
    _sum += value;
    for (final bucket in _buckets) {
      if (value <= bucket.boundary) {
        bucket.value++;
        return;
      }
    }
  }

  @override
  SampleGroup collect() {
    final now = DateTime.timestamp();
    return SampleGroup(
      this,
      [
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
      ],
    );
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
