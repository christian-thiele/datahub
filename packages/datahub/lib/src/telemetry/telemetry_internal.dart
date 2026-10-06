import 'dart:async';

/// Marks code of the telemetry itself (e.g. exporters), whose logs must not
/// be exported to a collector, since that could cause feedback loops when
/// the collector is unavailable.
abstract final class TelemetryInternal {
  static const _key = #datahub.telemetry.internal;

  static bool get isActive => Zone.current[_key] == true;

  static R run<R>(R Function() body) =>
      runZoned(body, zoneValues: {_key: true});
}
