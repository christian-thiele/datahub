import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/blocs/module/module_cubit.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/repositories/api_task_manager_repository.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/repositories/task_manager_repository.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/task_manager_module_page.dart';
import 'package:datahub_aperture_frontend/repositories/api_repository.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ModulePage extends StatelessWidget {
  final GoRouterState routerState;

  const ModulePage(this.routerState, {super.key});

  @override
  Widget build(BuildContext context) {
    final moduleId = routerState.pathParameters['moduleId']!;
    return BasePage(
      child: BlocProvider(
        key: ValueKey(moduleId),
        create: (context) => ModuleCubit(
          context.read<ResourcesRepository>(),
          moduleId: moduleId,
        ),
        child: BlocBuilder<ModuleCubit, ModuleState>(
          builder: (context, state) {
            return switch (state) {
              ModuleLoading() => LoadingView(),
              ModuleError(:final message) => ErrorView(
                message: message,
                onRetryPressed: () => context.read<ModuleCubit>().update(),
              ),
              ModuleLoaded(:final module) => switch (module.type) {
                ModuleType.taskManager => RepositoryProvider<TaskManagerRepository>(
                  create: (context) => ApiTaskManagerRepository(
                    module: module,
                    baseUrl: Bootstrap.of(context).baseUrl,
                  ),
                  dispose: (repository) => (repository as ApiRepository).close(),
                  child: TaskManagerModulePage(module: module),
                ),
                // ignore: unreachable_switch_case
                _ => ErrorView(
                  message:
                      'Module type not supported by this version of Aperture.',
                ),
              },
            };
          },
        ),
      ),
    );
  }
}
