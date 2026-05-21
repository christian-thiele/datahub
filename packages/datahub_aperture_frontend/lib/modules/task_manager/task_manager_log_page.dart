import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/task_manager_log_cubit.dart';
import 'blocs/task_manager_module_cubit.dart';
import 'repositories/task_manager_repository.dart';
import 'widgets/invocation_badge.dart';
import 'widgets/invocation_overview.dart';

class TaskManagerLogPage extends StatelessWidget {
  final String invocationId;

  const TaskManagerLogPage({super.key, required this.invocationId});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: BlocProvider(
        create: (context) => TaskManagerLogCubit(
          context.read<TaskManagerRepository>(),
          invocationId: invocationId,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          spacing: 16,
          children: [
            BlocBuilder<TaskManagerLogCubit, TaskManagerLogState>(
              builder: (context, state) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(switch (state) {
                      TaskManagerLogLoading() => '',
                      TaskManagerLogError() => '',
                      TaskManagerLogLoaded(:var taskModel) => taskModel.name,
                    }, style: Theme.of(context).textTheme.headlineMedium),
                    Spacer(),
                    switch (state) {
                      TaskManagerLogLoaded(:var taskModel) => InvocationBadge(
                        task: taskModel,
                      ),
                      _ => SizedBox.shrink(),
                    },
                  ],
                );
              },
            ),
            Expanded(
              child: BlocBuilder<TaskManagerLogCubit, TaskManagerLogState>(
                builder: (context, state) {
                  return switch (state) {
                    TaskManagerLogLoading() => LoadingView(),
                    ErrorState(:final message) => ErrorView(
                      message: message,
                      onRetryPressed: () =>
                          context.read<TaskManagerModuleCubit>().update(),
                    ),
                    TaskManagerLogLoaded(:final taskModel) =>
                      InvocationOverview(task: taskModel),
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
