const String helloWorldServiceFile = '''import 'package:datahub/datahub.dart';

/// What the service offers to other components, found with
/// `Find<HelloWorld>()`.
abstract interface class HelloWorld {
  void sayHello(DateTime time);
}

class HelloWorldService implements Service {
  const HelloWorldService();

  @override
  ServiceInstance<HelloWorldService> createInstance() =>
      _HelloWorldServiceInstance();
}

class _HelloWorldServiceInstance extends ServiceInstance<HelloWorldService>
    implements HelloWorld {
  @override
  Future<void> initialize() async {
    await super.initialize();
    log.info('Hello world service started.');
  }

  @override
  void sayHello(DateTime time) {
    log.info(
      'Hello from DataHub.',
      labels: {'hello_world.time': time.toIso8601String()},
    );
  }

  @override
  Future<void> dispose() async {
    log.info('Hello world service stops.');
    await super.dispose();
  }
}
''';
