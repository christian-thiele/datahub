import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/matchers.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/expect.dart';

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
        equals('datahub_instrumentation_scrape_duration'),
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

    expect(() => histogram.observe(1), throwsApiError());
    expect(() => histogram.observe(1, {'kind': 'other'}), throwsApiError());
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

    expect(() => histogram.observe(1, {'route': '/a'}), throwsApiError());
    expect(
      () => histogram.observe(1, {'route': '/a', 'status': '200', 'x': ''}),
      throwsApiError(),
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
