import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';

sealed class MetricCollector {
  void register();
}

abstract class SyncMetricCollector extends MetricCollector {
  SampleGroup collect();

  @override
  void register() {
    resolve<TelemetryService>().registerCollector(this);
  }
}

abstract class AsyncMetricCollector extends MetricCollector {
  Future<SampleGroup> collect();

  @override
  void register() {
    resolve<TelemetryService>().registerCollector(this);
  }
}
