import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/blocs/task_manager_module_cubit.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/repositories/task_manager_repository.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_list_view.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskManagerModulePage extends StatelessWidget {
  final ModuleDescription module;

  const TaskManagerModulePage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskManagerModuleCubit(
        context.read<TaskManagerRepository>(),
        module: module,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        spacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                module.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Spacer(),
              Builder(
                builder: (context) {
                  return IconButton.filled(
                    onPressed: () =>
                        context.read<TaskManagerModuleCubit>().update(),
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    tooltip: S.of(context).refresh,
                  );
                }
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<TaskManagerModuleCubit, TaskManagerModuleState>(
              builder: (context, state) {
                return switch (state) {
                  TaskManagerLoading() => LoadingView(),
                  TaskManagerError(:final message) => ErrorView(
                    message: message,
                    onRetryPressed: () =>
                        context.read<TaskManagerModuleCubit>().update(),
                  ),
                  TaskManagerLoaded(:final invocations) => InvocationTimeline(
                    tasks: invocations,
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
