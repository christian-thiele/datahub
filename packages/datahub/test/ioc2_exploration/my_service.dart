import 'dart:async';
import 'dart:math';

import 'package:datahub/scaffold.dart';

import 'compute_service.dart';

class TimerService implements Service {
  final Find<Compute> compute;

  const TimerService({this.compute = const Find<Compute>()});

  @override
  MyServiceInstance createInstance() => MyServiceInstance();
}

class MyServiceInstance extends ServiceInstance<TimerService> {
  late final Timer timer;

  @override
  FutureOr<void> initialize() async {
    print('MyServiceInstance: initialize');
    timer = Timer.periodic(const Duration(seconds: 2), _onTimer);
    print('MyServiceInstance: initialize -> done');
  }

  @override
  FutureOr<void> dispose() {
    timer.cancel();
  }

  void _onTimer(Timer t) async {
    final random = Random();
    final result = await find(service.compute)
        .computeSomething(random.nextInt(999), random.nextInt(999));
    print('Received result: $result');
  }
}
