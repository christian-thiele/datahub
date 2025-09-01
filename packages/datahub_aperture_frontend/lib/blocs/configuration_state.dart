part of 'configuration_cubit.dart';

@immutable
sealed class ConfigurationState {}

final class ConfigurationLoading extends ConfigurationState {
  final bool _initial;

  ConfigurationLoading({bool initial = false}) : _initial = initial;
}

final class ConfigurationValue extends ConfigurationState {
  final List<ResourceDescription> resources;

  ConfigurationValue({required this.resources});
}

final class ConfigurationError extends ConfigurationState {
  final String? message;

  ConfigurationError({required this.message});
}
