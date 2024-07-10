import 'dart:math';

import 'package:datahub/utils.dart';

import 'metric.dart';
import 'metric_sample.dart';

class CounterSeries {
  final Map<String, String> labels;
  num _value = 0;

  CounterSeries(this.labels);

  void inc() => ++_value;

  void incBy(num val) => _value += max(0, val);
}

class CounterMetric extends Metric {
  final _series = <CounterSeries>[];

  CounterMetric(
    super.name, {
    super.help,
    Map<String, List<String>>? labels,
  }) : super(type: MetricType.counter) {
    if (labels != null) {
      final combinations = everyCombination(labels.entries
          .map((e) => e.value.map((value) => MapEntry(e.key, value))));
      for (final combination in combinations) {
        _series.add(CounterSeries(Map.fromEntries(combination)));
      }
    } else {
      _series.add(CounterSeries(const {}));
    }
  }

  @override
  SampleGroup collect() {
    return SampleGroup(
      this,
      [
        for (final series in _series)
          MetricSample(
            name,
            series.labels,
            series._value,
            DateTime.timestamp(),
          ),
      ],
    );
  }

  CounterSeries _findSeries(Map<String, String> labels) {
    return _series.firstWhere(
      (s) => s.labels.entriesEqual(labels),
      orElse: () =>
          throw ApiError('No metric series matches given label combination.'),
    );
  }

  void inc([Map<String, String> labels = const {}]) {
    _findSeries(labels).inc();
  }

  void incBy(num val, [Map<String, String> labels = const {}]) =>
      _findSeries(labels).incBy(val);
}
