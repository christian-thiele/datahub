import 'package:datahub/scaffold.dart';

import '../telemetry_service.dart';
import 'sample_group.dart';

sealed class MetricCollector {
  void register();
}

abstract class SyncMetricCollector extends MetricCollector {
  SampleGroup collect();

  @override
  void register() {
    Find<Telemetry>().find().registerCollector(this);
  }
}

abstract class AsyncMetricCollector extends MetricCollector {
  Future<SampleGroup> collect();

  @override
  void register() {
    Find<Telemetry>().find().registerCollector(this);
  }
}
