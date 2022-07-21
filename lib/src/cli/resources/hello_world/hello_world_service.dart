const String helloWorldServiceFile = '''import 'package:datahub/datahub.dart';

class HelloWorldService extends BaseService {
  final log = resolve<LogService>();

  void sayHello(String str) {
    log.info('Hello from DataHub at \$str.');
  }

  @override
  Future<void> initialize() async {
    log.info('Hello world service prepares itself.');
  }

  @override
  Future<void> shutdown() async {
    log.info('Shutting down HelloWorld Service.');
  }
}
''';
