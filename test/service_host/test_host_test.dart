import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

class ExampleService extends BaseService {
  void doSomething() => print('I did something.');
}

class InitializeFailureService extends BaseService {
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 50));
    throw Exception('I cannot do anything right. :(');
  }
}

class InstantiateFailureService extends BaseService {
  final something = throw Exception('I cannot do anything right. :(');

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  group('Test Host', () {
    TestHost([ExampleService.new]).declare((host) {
      host.test(
        'Simple Service',
        () => resolve<ExampleService>().doSomething(),
      );
    });

    test(
      'Service Instantiate Failure',
      () => expect(TestHost([InstantiateFailureService.new]).setUp(),
          throwsA(isA<TestFailure>())),
    );

    test(
      'Service Initialize Failure',
      () => expect(TestHost([InitializeFailureService.new]).setUp(),
          throwsA(isA<TestFailure>())),
    );
  });
}
