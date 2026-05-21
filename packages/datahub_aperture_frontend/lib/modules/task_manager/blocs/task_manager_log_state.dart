part of 'task_manager_log_cubit.dart';

sealed class TaskManagerLogState {
  const TaskManagerLogState();
}

class TaskManagerLogLoading extends TaskManagerLogState {
  final bool _initial;

  const TaskManagerLogLoading() : _initial = false;

  const TaskManagerLogLoading.initial() : _initial = true;
}

class TaskManagerLogError extends TaskManagerLogState implements ErrorState {
  @override
  final String? message;

  const TaskManagerLogError({this.message});
}

class TaskManagerLogLoaded extends TaskManagerLogState {
  final TaskModel taskModel;

  const TaskManagerLogLoaded({required this.taskModel});
}
