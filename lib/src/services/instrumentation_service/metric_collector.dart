import 'package:datahub/ioc.dart';

import 'instrumentation_service.dart';
import 'metric_sample.dart';

abstract class MetricCollector {
  SampleGroup collect();

  void register() {
    resolve<InstrumentationService>().registerCollector(this);
  }
}
