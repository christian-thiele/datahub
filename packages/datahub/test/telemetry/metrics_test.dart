import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/test.dart';

void main() {
  declareTest('Test default metrics', [], () async {
    final instrumentation = Find<Telemetry>().find();
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
        equals('datahub_telemetry_scrape_duration_seconds'),
      ),
    );
    expect(metrics.first.samples.first.value, greaterThan(0));
  });

  declareTest('Test counter metrics', [], () async {
    final instrumentation = Find<Telemetry>().find();
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

  declareTest('Test counter metrics with labels', [], () async {
    final instrumentation = Find<Telemetry>().find();
    final counter = instrumentation.counter(
      'some_value',
      labels: {
        'yes_or_no': ['yes', 'no'],
        'version': ['1a', '2b', '3c'],
      },
    );

    expect(() => counter.inc(), returnsNormally);
    expect(() => counter.inc({'yes_or_no': 'no'}), returnsNormally);
    expect(
      () => counter.inc({'yes_or_no': 'no', 'version': '4d'}),
      returnsNormally,
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

  declareTest('Test gauge metrics', [], () async {
    final instrumentation = Find<Telemetry>().find();
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

  declareTest('Test gauge metrics with labels', [], () async {
    final instrumentation = Find<Telemetry>().find();
    final gauge = instrumentation.gauge(
      'some_value',
      labels: {
        'yes_or_no': ['yes', 'no'],
        'version': ['1a', '2b', '3c'],
      },
    );

    expect(() => gauge.inc(), returnsNormally);
    expect(() => gauge.inc({'yes_or_no': 'no'}), returnsNormally);
    expect(
      () => gauge.inc({'yes_or_no': 'no', 'version': '4d'}),
      returnsNormally,
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

  declareTest('Test histogram metrics without labels', [], () async {
    final instrumentation = Find<Telemetry>().find();
    final histogram = instrumentation.linearHistogram(
      'some_duration',
      start: 1,
      width: 4,
      count: 4,
    );
    histogram.observe(0.5);
    histogram.observe(2.5);

    final samples = await _samplesOf(instrumentation, 'some_duration');
    expect(
      samples.where((s) => s.name == 'some_duration_count').single.value,
      equals(2),
    );
    expect(
      samples.where((s) => s.name == 'some_duration_sum').single.value,
      equals(3),
    );
  });

  declareTest('Test histogram metrics with labels', [], () async {
    final instrumentation = Find<Telemetry>().find();
    final histogram = instrumentation.exponentialHistogram(
      'labeled_duration',
      start: 1,
      factor: 2,
      count: 3,
      labels: {
        'kind': ['read', 'write'],
      },
    );

    expect(() => histogram.observe(1), returnsNormally);
    expect(() => histogram.observe(1, {'kind': 'other'}), returnsNormally);
    histogram.observe(1.5, {'kind': 'read'});
    histogram.observe(3, {'kind': 'read'});
    histogram.observe(7, {'kind': 'write'});

    final samples = await _samplesOf(instrumentation, 'labeled_duration');
    num valueOf(String name, Map<String, String> labels) => samples
        .singleWhere((s) => s.name == name && s.labels.entriesEqual(labels))
        .value;

    expect(valueOf('labeled_duration_count', {'kind': 'read'}), equals(2));
    expect(valueOf('labeled_duration_sum', {'kind': 'read'}), equals(4.5));
    expect(valueOf('labeled_duration_count', {'kind': 'write'}), equals(1));
    expect(
      valueOf('labeled_duration_bucket', {'kind': 'read', 'le': '2'}),
      equals(1),
    );
    expect(
      valueOf('labeled_duration_bucket', {'kind': 'read', 'le': '+Inf'}),
      equals(2),
    );
    expect(
      valueOf('labeled_duration_bucket', {'kind': 'write', 'le': '4'}),
      equals(0),
    );
  });

  declareTest('Test histogram metrics with label names', [], () async {
    final telemetry = Find<Telemetry>().find();
    final histogram = telemetry.exponentialHistogram(
      'named_duration',
      start: 1,
      factor: 2,
      count: 3,
      labelNames: {'route', 'status'},
    );

    // no series before the first observation
    expect(await _samplesOf(telemetry, 'named_duration'), isEmpty);

    histogram.observe(0.5, {'route': '/a', 'status': '200'});
    histogram.observe(3, {'status': '200', 'route': '/a'});
    histogram.observe(1, {'route': '/b', 'status': '500'});

    expect(() => histogram.observe(1, {'route': '/a'}), returnsNormally);
    expect(
      () => histogram.observe(1, {'route': '/a', 'status': '200', 'x': ''}),
      returnsNormally,
    );

    final counts = (await _samplesOf(telemetry, 'named_duration'))
        .where((s) => s.name == 'named_duration_count')
        .map((s) => {...s.labels, 'count': s.value});
    expect(
      counts,
      unorderedEquals([
        {'route': '/a', 'status': '200', 'count': 2},
        {'route': '/b', 'status': '500', 'count': 1},
      ]),
    );
  });

  declareTest(
    'Test undeclared labels are dropped with one warning',
    [],
    () async {
      final telemetry = Find<Telemetry>().find();
      final counter = telemetry.counter(
        'dropping_total',
        labels: {
          'kind': ['a'],
        },
      );

      final warnings = <LogMessage>[];
      LogListener(
        onPublish: (message) {
          if (message.level == SeverityLevel.warning) {
            warnings.add(message);
          }
        },
      ).run(() {
        counter.inc({'kind': 'b'});
        counter.inc({'other': 'a'});
        counter.inc({'kind': 'a'});
      });

      expect(warnings, hasLength(1));
      expect(
        warnings.single.labels,
        equals({'datahub.metric.name': 'dropping_total'}),
      );
      final samples = await _samplesOf(telemetry, 'dropping_total');
      expect(samples.single.labels, equals({'kind': 'a'}));
      expect(samples.single.value, equals(1));
    },
  );

  declareTest('Test counters and gauges with label names', [], () async {
    final telemetry = Find<Telemetry>().find();
    final counter = telemetry.counter('named_total', labelNames: {'route'});
    final gauge = telemetry.gauge('named_gauge', labelNames: {'route'});

    expect(await _samplesOf(telemetry, 'named_total'), isEmpty);
    counter.inc({'route': '/a'});
    counter.incBy(2, {'route': '/a'});
    gauge.set(5, {'route': '/b'});

    final counted = await _samplesOf(telemetry, 'named_total');
    expect(counted.single.labels, equals({'route': '/a'}));
    expect(counted.single.value, equals(3));
    final gauged = await _samplesOf(telemetry, 'named_gauge');
    expect(gauged.single.labels, equals({'route': '/b'}));
    expect(gauged.single.value, equals(5));
  });

  declareTest('Test async collectors are scraped', [], () async {
    final telemetry = Find<Telemetry>().find();
    final collector = _SlowCollector();
    telemetry.registerCollector(collector);

    final groups = await telemetry.scrapeMetrics();
    expect(groups.map((g) => g.name), contains('slow_value'));
    // the scrape duration includes the async collector
    expect(groups.first.name, 'datahub_telemetry_scrape_duration_seconds');
    expect(groups.first.samples.single.value, greaterThanOrEqualTo(0.05));
    telemetry.unregisterCollector(collector);
  });

  test('Linear histogram buckets have the given width', () {
    final histogram = HistogramMetric.linear(
      'linear',
      start: 1,
      width: 4,
      count: 4,
    );
    expect(histogram.boundaries, equals([1, 5, 9, 13]));
  });

  declareTest('Test histogram with explicit buckets', [], () async {
    final telemetry = Find<Telemetry>().find();
    final histogram = telemetry.histogram(
      'explicit_seconds',
      buckets: HistogramMetric.defaultDurationBuckets,
    );
    histogram.observeDuration(const Duration(milliseconds: 20));

    final buckets = {
      for (final sample in await _samplesOf(telemetry, 'explicit_seconds'))
        if (sample.name == 'explicit_seconds_bucket')
          sample.labels['le']: sample.value,
    };
    expect(buckets['0.01'], equals(0));
    expect(buckets['0.025'], equals(1));
    expect(buckets['10'], equals(1));
    expect(buckets['+Inf'], equals(1));
  });

  declareTest('Test exception events carry the error message', [], () async {
    final event = ExceptionEvent(
      error: StateError('boom'),
      timestamp: DateTime.timestamp(),
    );
    expect(event.attributes['exception.type'], equals('StateError'));
    expect(event.attributes['exception.message'], equals('Bad state: boom'));
  });
}

Future<List<MetricSample>> _samplesOf(Telemetry telemetry, String name) async {
  final groups = await telemetry.scrapeMetrics();
  return groups
      .where((g) => g.metric.name == name)
      .expand((g) => g.samples)
      .toList();
}

class _SlowCollector extends AsyncMetricCollector {
  final metric = GaugeMetric('slow_value');

  @override
  Future<SampleGroup> collect() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return metric.collect();
  }
}
