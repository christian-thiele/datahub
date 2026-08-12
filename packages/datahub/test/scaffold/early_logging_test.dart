import 'dart:async';

import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:test/test.dart';

/// A host that builds an arbitrary component tree, in particular one without a
/// [TelemetryService].
class BareHost extends ServiceHost {
  final Component root;

  BareHost(this.root);

  @override
  Component buildRoot() => root;
}

class BoomException implements Exception {
  @override
  String toString() => 'BoomException: service could not start';
}

/// A service that fails during initialization.
class FailingService implements Service {
  const FailingService();

  @override
  ServiceInstance createInstance() => FailingServiceInstance();
}

class FailingServiceInstance extends ServiceInstance<FailingService> {
  @override
  Future<void> initialize() async {
    await super.initialize();
    throw BoomException();
  }
}

/// A service that logs during initialization.
class LoggingService implements Service {
  const LoggingService();

  @override
  ServiceInstance createInstance() => LoggingServiceInstance();
}

class LoggingServiceInstance extends ServiceInstance<LoggingService> {
  @override
  Future<void> initialize() async {
    log.warn('a warning with no telemetry to publish to');
    print('a plain print with no telemetry to publish to');
    await super.initialize();
  }
}

void main() {
  group('Logging before telemetry exists', () {
    // ServiceHost logs the reason a component failed to start via log.fatal.
    // That lookup used to be non-nullable, so logging threw
    // "Could not find component with Find<Telemetry>" and buried the actual
    // error whenever a component failed before telemetry was up.
    test('an initialization failure is reported as itself', () async {
      final host = BareHost(
        Scope(name: 'root', components: [const FailingService()]),
      );

      await expectLater(host.initialize(), throwsA(isA<BoomException>()));
    });

    test('log() falls back to printing instead of throwing', () async {
      final host = BareHost(
        Scope(name: 'root', components: [const LoggingService()]),
      );

      final printed = <String>[];
      await runZoned(
        host.initialize,
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) => printed.add(line),
        ),
      );
      addTearDown(host.shutdown);

      expect(printed, hasLength(2));
      expect(printed.first, contains('a warning'));
      expect(printed.last, contains('a plain print'));
    });
  });
}
