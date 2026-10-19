enum MetricType() {
  counter,
  gauge,
  histogram,
  summary,
}

class MetricSample(
  final String name,
  final Map<String, String> labels,
  final num value,
  final DateTime timestamp,
);
