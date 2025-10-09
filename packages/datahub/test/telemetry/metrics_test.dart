import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/matchers.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/expect.dart';

void main() {
  TestHost([]).declare((host) {
    host.test('Test default metrics', () async {
      final instrumentation = resolve<TelemetryService>();
      final metrics = await instrumentation.scrapeMetrics();
      expect(metrics, isNotEmpty);
      expect(
        metrics.first,
        isA<SampleGroup>().having((s) => s.samples, 'samples', isNotEmpty),
      );
      expect(
        metrics.first.samples.first,
        isA<MetricSample>().having(
          (s) => s.name,
          'name',
          equals('datahub_instrumentation_scrape_duration'),
        ),
      );
      expect(metrics.first.samples.first.value, greaterThan(0));
    });

    host.test('Test counter metrics', () async {
      final instrumentation = resolve<TelemetryService>();
      final counter = instrumentation.counter('some_value');
      for (var i = 0; i < 3; i++) {
        counter.inc();
      }

      final metrics = await instrumentation.scrapeMetrics();
      expect(metrics, isNotEmpty);
      expect(
        metrics.last,
        isA<SampleGroup>().having((s) => s.samples, 'samples', isNotEmpty),
      );
      expect(
        metrics.last.samples.first,
        isA<MetricSample>().having((s) => s.name, 'name', equals('some_value')),
      );
      expect(metrics.last.samples.first.value, equals(3));
    });

    host.test('Test counter metrics with labels', () async {
      final instrumentation = resolve<TelemetryService>();
      final counter = instrumentation.counter(
        'some_value',
        labels: {
          'yes_or_no': ['yes', 'no'],
          'version': ['1a', '2b', '3c'],
        },
      );

      expect(() => counter.inc(), throwsApiError());
      expect(() => counter.inc({'yes_or_no': 'no'}), throwsApiError());
      expect(
        () => counter.inc({'yes_or_no': 'no', 'version': '4d'}),
        throwsApiError(),
      );

      counter.inc({'yes_or_no': 'yes', 'version': '2b'});
      counter.inc({'yes_or_no': 'no', 'version': '3c'});
      counter.incBy(3, {'yes_or_no': 'yes', 'version': '1a'});
      counter.incBy(-5, {
        'yes_or_no': 'no',
        'version': '1a',
      }); // should not do anything

      final metrics = await instrumentation.scrapeMetrics();
      expect(metrics, isNotEmpty);
      expect(
        metrics.last,
        isA<SampleGroup>().having((s) => s.samples, 'samples', isNotEmpty),
      );
      expect(
        metrics.last.samples,
        unorderedEquals([
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'yes', 'version': '1a'}),
              )
              .having((s) => s.value, 'value', equals(3)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'yes', 'version': '2b'}),
              )
              .having((s) => s.value, 'value', equals(1)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'yes', 'version': '3c'}),
              )
              .having((s) => s.value, 'value', equals(0)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'no', 'version': '1a'}),
              )
              .having((s) => s.value, 'value', equals(0)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'no', 'version': '2b'}),
              )
              .having((s) => s.value, 'value', equals(0)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'no', 'version': '3c'}),
              )
              .having((s) => s.value, 'value', equals(1)),
        ]),
      );
    });

    host.test('Test gauge metrics', () async {
      final instrumentation = resolve<TelemetryService>();
      final gauge = instrumentation.gauge('some_value');
      for (var i = 0; i < 3; i++) {
        gauge.inc();
      }
      gauge.incBy(-5);

      final metrics = await instrumentation.scrapeMetrics();
      expect(metrics, isNotEmpty);
      expect(
        metrics.last,
        isA<SampleGroup>().having((s) => s.samples, 'samples', isNotEmpty),
      );
      expect(
        metrics.last.samples.first,
        isA<MetricSample>().having((s) => s.name, 'name', equals('some_value')),
      );
      expect(metrics.last.samples.first.value, equals(-2));
    });

    host.test('Test gauge metrics with labels', () async {
      final instrumentation = resolve<TelemetryService>();
      final gauge = instrumentation.gauge(
        'some_value',
        labels: {
          'yes_or_no': ['yes', 'no'],
          'version': ['1a', '2b', '3c'],
        },
      );

      expect(() => gauge.inc(), throwsApiError());
      expect(() => gauge.inc({'yes_or_no': 'no'}), throwsApiError());
      expect(
        () => gauge.inc({'yes_or_no': 'no', 'version': '4d'}),
        throwsApiError(),
      );

      gauge.inc({'yes_or_no': 'yes', 'version': '2b'});
      gauge.incBy(1, {'yes_or_no': 'no', 'version': '3c'});

      final metrics = await instrumentation.scrapeMetrics();
      expect(metrics, isNotEmpty);
      expect(
        metrics.last,
        isA<SampleGroup>().having((s) => s.samples, 'samples', isNotEmpty),
      );
      expect(
        metrics.last.samples,
        unorderedEquals([
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'yes', 'version': '1a'}),
              )
              .having((s) => s.value, 'value', equals(0)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'yes', 'version': '2b'}),
              )
              .having((s) => s.value, 'value', equals(1)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'yes', 'version': '3c'}),
              )
              .having((s) => s.value, 'value', equals(0)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'no', 'version': '1a'}),
              )
              .having((s) => s.value, 'value', equals(0)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'no', 'version': '2b'}),
              )
              .having((s) => s.value, 'value', equals(0)),
          isA<MetricSample>()
              .having((s) => s.name, 'name', equals('some_value'))
              .having(
                (s) => s.labels,
                'labels',
                equals({'yes_or_no': 'no', 'version': '3c'}),
              )
              .having((s) => s.value, 'value', equals(1)),
        ]),
      );
    });
  });
}
