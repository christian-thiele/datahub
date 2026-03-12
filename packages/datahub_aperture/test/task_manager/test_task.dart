import 'package:datahub/data.dart';

part 'test_task.g.dart';

@Data()
class TestTask extends $TestTask {
  final String message;
  final bool shouldFail;

  const TestTask({required this.message, required this.shouldFail});
}
