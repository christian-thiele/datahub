import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/blocs/task_manager_module_cubit.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/repositories/task_manager_repository.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_list_view.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskManagerModulePage extends StatelessWidget {
  const TaskManagerModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: BlocProvider(
        create: (context) =>
            TaskManagerModuleCubit(context.read<TaskManagerRepository>()),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          spacing: 20,
          children: [
            Builder(
              builder: (context) {
                return PageHeader(
                  title: 'Task Manager',
                  leading: IconTile(Icons.task_alt, size: 40),
                  actions: [
                    IconButton.outlined(
                      onPressed: () =>
                          context.read<TaskManagerModuleCubit>().update(),
                      icon: Icon(Icons.refresh),
                      tooltip: S.of(context).refresh,
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child:
                  BlocBuilder<TaskManagerModuleCubit, TaskManagerModuleState>(
                    builder: (context, state) {
                      return switch (state) {
                        TaskManagerLoading() => LoadingView(),
                        ErrorState(:final message) => ErrorView(
                          message: message,
                          onRetryPressed: () =>
                              context.read<TaskManagerModuleCubit>().update(),
                        ),
                        TaskManagerLoaded(:final invocations) =>
                          InvocationTimeline(tasks: invocations),
                      };
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
