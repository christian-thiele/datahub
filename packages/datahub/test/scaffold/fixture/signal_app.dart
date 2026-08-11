import 'dart:async';

import 'package:datahub/datahub.dart';

/// Fixture app for signal_shutdown_test.dart.
///
/// Prints marker lines so the test can observe the lifecycle of the host
/// from outside the process.
class MarkerService implements Service {
  @override
  ServiceInstance<MarkerService> createInstance() => MarkerServiceInstance();
}

class MarkerServiceInstance extends ServiceInstance<MarkerService> {
  @override
  FutureOr<void> initialize() async {
    await super.initialize();
    print('MARKER_INITIALIZED');
  }

  @override
  FutureOr<void> dispose() async {
    print('MARKER_DISPOSED');
    await super.dispose();
  }
}

void main() async {
  await runApp([MarkerService()]);
  print('MARKER_EXITED');
}
