part of 'task_manager_module_cubit.dart';

sealed class TaskManagerModuleState {
  const TaskManagerModuleState();
}

class TaskManagerLoading extends TaskManagerModuleState {
  final Paging paging;
  final bool _initial;

  const TaskManagerLoading({required this.paging}) : _initial = false;

  const TaskManagerLoading.initial()
    : _initial = true,
      paging = const Paging.empty(0, 25);
}

class TaskManagerError extends TaskManagerModuleState implements ErrorState {
  @override
  final String? message;

  const TaskManagerError({this.message});
}

class TaskManagerLoaded extends TaskManagerModuleState {
  final Paging paging;
  final List<TaskDescription> descriptions;
  final List<TaskModel> invocations;

  TaskManagerLoaded({
    required this.paging,
    required this.descriptions,
    required this.invocations,
  });
}
