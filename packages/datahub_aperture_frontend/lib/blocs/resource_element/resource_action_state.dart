part of 'resource_action_cubit.dart';

sealed class ResourceActionState {
  final String resourceId;
  final String actionId;
  final String elementId;

  const ResourceActionState({
    required this.resourceId,
    required this.actionId,
    required this.elementId,
  });
}

class ResourceActionLoading extends ResourceActionState {
  const ResourceActionLoading({
    required super.resourceId,
    required super.actionId,
    required super.elementId,
  });
}

class ResourceActionProgress extends ResourceActionState {
  final TaskDescription? taskDescription;
  final TaskModel task;

  const ResourceActionProgress({
    required super.resourceId,
    required super.actionId,
    required super.elementId,
    required this.taskDescription,
    required this.task,
  });
}

class ResourceActionDone extends ResourceActionState {
  const ResourceActionDone({
    required super.resourceId,
    required super.actionId,
    required super.elementId,
  });
}

class ResourceActionError extends ResourceActionState implements ErrorState {
  @override
  final String? message;

  const ResourceActionError({
    required super.resourceId,
    required super.actionId,
    required super.elementId,
    this.message,
  });
}
