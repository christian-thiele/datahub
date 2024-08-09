import 'metric_collector.dart';
import 'metric_sample.dart';

abstract class Metric extends MetricCollector {
  final String name;
  final String? help;
  final MetricType type;

  Metric(
    this.name, {
    required this.type,
    String? help,
  }) : help = help?.replaceAll('\\', '\\\\').replaceAll('\n', '\\n') {
    if (!RegExp('^[a-zA-Z_:][a-zA-Z0-9_:]*\$').hasMatch(name)) {
      throw Exception('Invalid metric name "$name".');
    }
  }

  @override
  String toString() => 'Metric(name: $name, type: ${type.name})';
}
