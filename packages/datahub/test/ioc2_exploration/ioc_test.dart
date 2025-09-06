import 'dart:async';
import 'dart:math';

import 'package:datahub/scaffold.dart';
import 'package:test/test.dart';

import 'compute_service.dart';
import 'other_compute_service.dart';

class MyService implements Service {
  final Find<Compute> compute;

  const MyService({this.compute = const Find<Compute>()});

  @override
  MyServiceInstance createInstance() => MyServiceInstance();
}

class MyServiceInstance extends ServiceInstance<MyService> {
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

void main() {
  test('IOC2 Test', () async {
    final host = ApplicationHost(
      components: [
        ComputeService(),
        MyService(),
      ],
    );

    Timer(const Duration(seconds: 15), () => host.shutdown());
    await host.run();
  }, skip: true);

  test('IOC2 Ambiguous', () async {
    final host = ApplicationHost(
      components: [
        Scope(
          components: [
            ComputeService(),
            MyService(compute: Find<OtherComputeServiceInstance>()),
          ],
        ),
        OtherComputeService(),
      ],
    );

    Timer(const Duration(seconds: 15), () => host.shutdown());
    await host.run();
  }, skip: true);

  test('IOC2 Configuration tree', () async {
    final host = ApplicationHost(
      components: [
        ConfigService(value: '123'),
        Scope(components: [
          ConfigService(value: '456'),
          Scope(components: [
            ReadService(),
          ]),
        ]),
      ],
    );
    Timer(const Duration(seconds: 5), () => host.shutdown());
    await host.run();
  });
}

abstract interface class Config {
  dynamic get<T>(String name);
}

class ConfigService implements Service {
  final String value;

  ConfigService({required this.value});

  @override
  ServiceInstance<Service> createInstance() => ConfigInstance();
}

class ConfigInstance extends ServiceInstance<ConfigService> implements Config {
  @override
  get<T>(String name) {
    return service.value;
  }
}

class ReadService implements Service {
  @override
  ServiceInstance<Service> createInstance() => ReadServiceInstance();
}

class ReadServiceInstance extends ServiceInstance<ReadService> {
  @override
  FutureOr<void> initialize() {
    print(find(Find<Config>()).get('abc'));
  }
}
