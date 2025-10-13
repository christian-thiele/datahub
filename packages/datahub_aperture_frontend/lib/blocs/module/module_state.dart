part of 'module_cubit.dart';

sealed class ModuleState {
  const ModuleState();
}

class ModuleLoading extends ModuleState {
  final bool _initial;
  const ModuleLoading([this._initial = false]);
}

class ModuleLoaded extends ModuleState {
  final ModuleDescription module;

  const ModuleLoaded({required this.module});
}

class ModuleError extends ModuleState implements ErrorState {
  @override
  final String? message;

  const ModuleError({this.message});
}
