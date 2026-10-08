part of 'resource_action_cubit.dart';

sealed class ResourceActionState {
  const ResourceActionState();
}

class ResourceActionEditing extends ResourceActionState {
  final Map<String, dynamic> values;
  final Map<String, String> validation;

  const ResourceActionEditing({required this.values, required this.validation});
}

class ResourceActionLoading extends ResourceActionState {
  const ResourceActionLoading();
}

class ResourceActionDone extends ResourceActionState {
  /// What the action responded with, null for signals.
  final ResourceActionResult? result;

  const ResourceActionDone({this.result});
}

class ResourceActionError extends ResourceActionState implements ErrorState {
  @override
  final String? message;

  const ResourceActionError({this.message});
}
