part of 'configuration_cubit.dart';

sealed class ConfigurationState {}

final class ConfigurationLoading extends ConfigurationState {
  final bool _initial;

  ConfigurationLoading({bool initial = false}) : _initial = initial;
}

final class ConfigurationValue extends ConfigurationState {
  final List<ResourceDescription> resources;
  final List<ModuleDescription> modules;
  final List<ResourceAction> actions;

  ConfigurationValue({
    required this.resources,
    required this.modules,
    required this.actions,
  });
}

final class ConfigurationError extends ConfigurationState
    implements ErrorState {
  @override
  final String? message;

  ConfigurationError({required this.message});
}
