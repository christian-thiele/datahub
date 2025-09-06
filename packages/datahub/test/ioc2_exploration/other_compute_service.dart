import 'dart:async';

import 'package:datahub/scaffold.dart';

import 'compute_service.dart';

class OtherComputeService implements Service {
  @override
  ServiceInstance<Service> createInstance() => OtherComputeServiceInstance();
}

class OtherComputeServiceInstance extends ServiceInstance<OtherComputeService>
    implements Compute {
  @override
  Future<int> computeSomething(int a, int b) async {
    print('OtherComputeServiceInstance: computeSomething');
    return 1337;
  }
}
