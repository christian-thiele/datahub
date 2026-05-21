part of 'configuration_cubit.dart';

sealed class ConfigurationState {}

final class ConfigurationLoading extends ConfigurationState {
  final bool _initial;

  ConfigurationLoading({bool initial = false}) : _initial = initial;
}

final class ConfigurationValue extends ConfigurationState {
  final List<ResourceDescription> resources;
  final List<ModuleDescription> modules;

  ConfigurationValue({required this.resources, required this.modules});
}

final class ConfigurationError extends ConfigurationState
    implements ErrorState {
  @override
  final String? message;

  ConfigurationError({required this.message});
}
