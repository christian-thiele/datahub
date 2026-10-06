import 'package:datahub/utils.dart';

import '../logs/log_helper.dart';

/// The series of a metric, one for each combination of label values.
///
/// Labels are declared either with all of their values (`labels`), which
/// creates a series for every combination upfront, or by name only
/// (`labelNames`), which creates a series when a combination is first used.
/// Recording for labels that were not declared logs a warning (once per
/// metric) and drops the value, so telemetry never fails the code that
/// records it.
class MetricSeriesSet<S> {
  final String metricName;
  final Set<String>? labelNames;
  final S Function(Map<String, String> labels) _create;
  final _series = <String, S>{};
  bool _warned = false;

  MetricSeriesSet(
    this.metricName, {
    Map<String, List<String>>? labels,
    this.labelNames,
    required S Function(Map<String, String> labels) create,
  }) : assert(
         labels == null || labelNames == null,
         'Labels are declared either with their values or by name.',
       ),
       _create = create {
    if (labelNames != null) {
      // series are created when used
    } else if (labels != null && labels.isNotEmpty) {
      final combinations = cartesianProduct(
        labels.entries.map(
          (e) => e.value.map((value) => MapEntry(e.key, value)),
        ),
      );
      for (final combination in combinations) {
        final labels = Map<String, String>.fromEntries(combination);
        _series[_key(labels)] = _create(labels);
      }
    } else {
      _series[_key(const {})] = _create(const {});
    }
  }

  Iterable<S> get values => _series.values;

  /// The series of [labels], or null if [labels] were not declared.
  S? find(Map<String, String> labels) {
    final key = _key(labels);
    if (_series[key] case final series?) {
      return series;
    }

    if (labelNames case final names?
        when labels.length == names.length && names.containsAll(labels.keys)) {
      return _series[key] = _create(Map.unmodifiable(labels));
    }

    if (!_warned) {
      _warned = true;
      log.warn(
        'Metric "$metricName" has no series for the labels $labels, '
        'dropping the value. Further mismatches are not logged.',
        labels: {'datahub.metric.name': metricName},
      );
    }
    return null;
  }

  static String _key(Map<String, String> labels) {
    final names = labels.keys.toList()..sort();
    return [
      for (final name in names) '$name\u0000${labels[name]}',
    ].join('\u0001');
  }
}
