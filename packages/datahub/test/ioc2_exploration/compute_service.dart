import 'dart:async';

import 'package:datahub/scaffold.dart';

abstract interface class Compute {
  Future<int> computeSomething(int a, int b);
}

class ComputeService implements Service {
  @override
  ServiceInstance<ComputeService> createInstance() => ComputeServiceInstance();
}

final class ComputeServiceInstance extends ServiceInstance<ComputeService>
    implements Compute {
  @override
  FutureOr<void> dispose() async {}

  @override
  FutureOr<void> initialize() async {}

  @override
  Future<int> computeSomething(int a, int b) async {
    print('ComputeServiceInstance: computeSomething');
    return a + b;
  }
}
