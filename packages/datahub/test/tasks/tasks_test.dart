import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';

import 'memory_repository.dart';

part 'tasks_test.g.dart';

@Data()
class TestJob extends $TestJob {
  final String param1;
  final int param2;

  const TestJob({required this.param1, required this.param2});
}

Future<void> _jobDelegate(TaskProgress progress, TestJob testJob) async {
  log('Job started with params ${testJob.param1}, ${testJob.param2}');
  await Future.delayed(const Duration(seconds: 1));
  progress.reportProgress(0.3);
  await Future.delayed(const Duration(seconds: 1));
  progress.reportProgress(0.6);
  await Future.delayed(const Duration(seconds: 1));
  progress.reportProgress(0.9);
  log('Job finished');
}

void main() {
  declareTest(
    'Run Task',
    [MemoryRepositoryService(bean: $TaskInvocation.bean), TaskManagerService()],
    () async {
      final taskManager = Find<TaskManager>().find();
      final scheduler = await taskManager.registerExecutor<TestJob>(
        'test-job',
        $TestJob.bean,
        _jobDelegate,
      );
      scheduler.scheduleInvocation(TestJob(param1: 'abc123', param2: 456));
      await Future.delayed(const Duration(seconds: 1));
    },
  );
}
