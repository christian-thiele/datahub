import 'package:datahub/scaffold.dart';

import '../telemetry_service.dart';

sealed class MetricCollector {
  void register();
}

abstract class SyncMetricCollector extends MetricCollector {
  SampleGroup collect();

  @override
  void register() {
    Context.ofZone().find(Find<Telemetry>()).registerCollector(this);
  }
}

abstract class AsyncMetricCollector extends MetricCollector {
  Future<SampleGroup> collect();

  @override
  void register() {
    Context.ofZone().find(Find<Telemetry>()).registerCollector(this);
  }
}
