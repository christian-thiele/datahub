import 'package:datahub/datahub.dart';
import 'package:datahub/src/services/instrumentation_service/metric_sample.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/expect.dart';

void main() {
  TestHost([]).declare((host) {
    host.test('Test default metrics', () {
      final instrumentation = resolve<InstrumentationService>();
      final metrics = instrumentation.scrape();
      expect(metrics, isNotEmpty);
      expect(metrics.first,
          isA<SampleGroup>().having((s) => s.samples, 'samples', isNotEmpty));
      expect(
          metrics.first.samples.first,
          isA<MetricSample>().having((s) => s.name, 'name',
              equals('datahub_instrumentation_scrape_duration')));
      expect(metrics.first.samples.first.value, greaterThan(0));
    });
  });
}
