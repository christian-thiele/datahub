import 'metric_collector.dart';
import 'metric_sample.dart';

abstract class Metric(
  final String name, {
  required final MetricType type,
  String? help,
}) extends SyncMetricCollector {
  final String? help = help?.replaceAll('\\', '\\\\').replaceAll('\n', '\\n');
  this {
    if (!RegExp('^[a-zA-Z_:][a-zA-Z0-9_:]*\$').hasMatch(name)) {
      throw Exception('Invalid metric name "$name".');
    }
  }

  @override
  String toString() => 'Metric(name: $name, type: ${type.name})';
}
