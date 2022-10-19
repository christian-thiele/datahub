import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

class ExampleService extends BaseService {
  final _log = resolve<LogService>();

  void doSomething() {
    _log.i('I did something.');
  }

  double failSomehow() {
    return throw Exception('I cannot do anything right. :(');
  }
}

void main() {
  group('Test Host', () {
    test(
        'Simple Test',
        TestHost([ExampleService.new]).test(() {
          resolve<ExampleService>().doSomething();
        }));
  });
}
