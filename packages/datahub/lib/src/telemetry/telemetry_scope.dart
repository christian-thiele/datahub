/// An instrumentation scope, e.g. a [Tracer].
abstract class TelemetryScope {
  String get name;
  String? get version;
  Map<String, dynamic> get attributes;
}

/// A [TelemetryScope] that only consists of its values.
class SimpleTelemetryScope implements TelemetryScope {
  @override
  final String name;
  @override
  final String? version;
  @override
  final Map<String, dynamic> attributes;

  const SimpleTelemetryScope(
    this.name, {
    this.version,
    this.attributes = const {},
  });
}
