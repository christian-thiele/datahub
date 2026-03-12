import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

import '../_utils/test_auth_provider.dart';
import 'test_task.dart';

void main(List<String> args) => runApp([
  KeyService(),
  MemoryRepositoryService(bean: $TaskInvocation.bean),
  TaskManagerService(),
  TestAuthProvider(),
  ApiService(
    routes: [
      ApertureApi(
        configDelegate: ApertureConfigStaticDelegate(
          baseUrl: 'http://localhost:8080/aperture',
          modules: [TaskManagerModule()],
        ),
        oidcIssuer: Config.value('http://localhost:8081/realms/local-oidc'),
        oidcClientId: Config.value('aperture'),
      ),
    ],
  ),
  ServiceDelegate(
    initialize: () async {
      final executor = await Find<TaskManager>().find().registerExecutor(
        'test-task',
        $TestTask.bean,
        (progress, params) async {
          log('Running: ${params.message}');
          for (final i in Iterable.generate(10)) {
            await Future.delayed(const Duration(milliseconds: 10000));
            progress.reportProgress(i / 10);
            log('This is step $i');
          }

          if (params.shouldFail) {
            throw ApiRequestException.notFound('Task is intended to fail.');
          }
        },
      );

      executor.scheduleInvocation(
        TestTask(message: 'not failing', shouldFail: false),
      );
      executor.scheduleInvocation(
        TestTask(message: 'failing', shouldFail: true),
      );
    },
  ),
], arguments: args);
