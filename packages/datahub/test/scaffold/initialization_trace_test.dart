import 'package:datahub/datahub.dart';
import 'package:datahub/src/telemetry/opentelemetry-dart/open_telemetry.dart'
    as otel;
import 'package:test/test.dart';

import '../telemetry/_fake_collector.dart';

class _Host extends ServiceHost {
  final List<Component> beforeTelemetry;
  final List<Component> components;

  _Host(this.components, {this.beforeTelemetry = const []});

  @override
  Component buildRoot() => Scope(
    components: [
      ...beforeTelemetry,
      TelemetryService(),
      Scope(components: components),
    ],
  );
}

/// Takes [_SlowService.duration] to initialize.
class _SlowService implements Service {
  static const duration = Duration(milliseconds: 50);

  const _SlowService();

  @override
  ServiceInstance createInstance() => _SlowServiceInstance();
}

class _SlowServiceInstance extends ServiceInstance<_SlowService> {
  @override
  Future<void> initialize() async {
    await super.initialize();
    await Future<void>.delayed(_SlowService.duration);
  }
}

/// Registers a [_ChildService] and keeps the active span of its
/// initialization.
class _ParentService implements Service {
  const _ParentService();

  @override
  ServiceInstance createInstance() => _ParentServiceInstance();
}

class _ParentServiceInstance extends ServiceInstance<_ParentService> {
  Span? span;

  @override
  Future<void> initialize() async {
    await super.initialize();
    span = Tracer.currentSpan;
    registry.register(const _ChildService());
  }
}

class _ChildService implements Service {
  const _ChildService();

  @override
  ServiceInstance createInstance() => _ChildServiceInstance();
}

class _ChildServiceInstance extends ServiceInstance<_ChildService> {}

/// Fails to initialize, after passing its active span to [onSpan].
class _FailingService implements Service {
  final void Function(Span? span) onSpan;

  const _FailingService(this.onSpan);

  @override
  ServiceInstance createInstance() => _FailingServiceInstance();
}

class _FailingServiceInstance extends ServiceInstance<_FailingService> {
  @override
  Future<void> initialize() async {
    await super.initialize();
    service.onSpan(Tracer.currentSpan);
    throw StateError('service could not start');
  }
}

Future<void> main() async {
  final collector = FakeCollector();
  await collector.server.serve(port: 0);
  tearDownAll(() => collector.server.shutdown());

  test('traces the initialization of every service', () async {
    final host = _Host(
      [const _ParentService()],
      beforeTelemetry: [const _SlowService()],
    );
    host.configuration.addConfigMap({
      'telemetry': {
        'openTelemetryExporter': {
          'enable': true,
          'host': 'localhost',
          'port': collector.server.port,
          'exportInterval': 100,
          'exportIntervalJitter': 0,
        },
      },
    });

    await host.initialize();
    final parentSpan = host
        .findComponent(Find<_ParentServiceInstance>(), null)
        .span;
    // flushes the exporter
    await host.shutdown();

    // the final state of every span
    final spans = <String, otel.Span>{
      for (final span in collector.spans)
        if (span.endTimeUnixNano > 0) span.name: span,
    };
    expect(
      spans.keys,
      unorderedEquals([
        'initialize _Host',
        'initialize _SlowService',
        'initialize TelemetryService',
        'initialize _ParentService',
        'initialize _ChildService',
      ]),
    );

    final root = spans['initialize _Host']!;
    final slow = spans['initialize _SlowService']!;
    final telemetry = spans['initialize TelemetryService']!;
    final parent = spans['initialize _ParentService']!;
    final child = spans['initialize _ChildService']!;

    expect(root.parentSpanId, isEmpty);
    expect(slow.parentSpanId, equals(root.spanId));
    expect(telemetry.parentSpanId, equals(root.spanId));
    expect(parent.parentSpanId, equals(root.spanId));
    expect(child.parentSpanId, equals(parent.spanId));
    for (final span in spans.values) {
      expect(span.traceId, equals(root.traceId));
    }

    void expectWithin(otel.Span span, otel.Span parent) {
      expect(
        span.startTimeUnixNano,
        greaterThanOrEqualTo(parent.startTimeUnixNano),
      );
      expect(
        span.endTimeUnixNano,
        greaterThanOrEqualTo(span.startTimeUnixNano),
      );
      expect(span.endTimeUnixNano, lessThanOrEqualTo(parent.endTimeUnixNano));
    }

    expectWithin(slow, root);
    expectWithin(telemetry, root);
    expectWithin(parent, root);
    expectWithin(child, parent);
    expect(
      telemetry.endTimeUnixNano,
      lessThanOrEqualTo(parent.startTimeUnixNano),
    );

    // spans created before the telemetry was initialized are backdated
    expect(
      (slow.endTimeUnixNano - slow.startTimeUnixNano).toInt(),
      greaterThanOrEqualTo(_SlowService.duration.inMicroseconds * 1000),
    );
    expect(
      slow.endTimeUnixNano,
      lessThanOrEqualTo(telemetry.startTimeUnixNano),
    );

    // the span is active while the service initializes
    expect(parentSpan?.spanId.bytes, equals(parent.spanId));
  });

  test('fails the spans of a service that cannot initialize', () async {
    Span? span;
    final host = _Host([_FailingService((s) => span = s)]);

    await expectLater(host.initialize(), throwsStateError);

    expect(span, isA<LocalSpan>());
    final service = span as LocalSpan;
    expect(service.name, equals('initialize _FailingService'));
    expect(service.isEnded, isTrue);
    expect(service.hasError, isTrue);
    expect(service.events.map((e) => e.name), equals(['exception']));

    final root = service.parent as LocalSpan;
    expect(root.name, equals('initialize _Host'));
    expect(root.isEnded, isTrue);
    expect(root.hasError, isTrue);
  });
}
