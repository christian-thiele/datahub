part of 'test_host.dart';

class const TestRunnerService() implements Service {
  @override
  ServiceInstance<TestRunnerService> createInstance() =>
      _TestRunnerServiceInstance();
}

class _TestRunnerServiceInstance() extends ServiceInstance<TestRunnerService> {
  Future<void> runTest(FutureOr<void> Function() testBody) async {
    await context.run(testBody);
  }
}
