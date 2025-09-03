part of 'bootstrap_cubit.dart';

sealed class BootstrapState {}

final class BootstrapLoading extends BootstrapState {}

final class BootstrapSuccess extends BootstrapState {
  final ApertureBootstrap bootstrap;

  BootstrapSuccess({required this.bootstrap});
}

final class BootstrapError extends BootstrapState {
  final String? message;

  BootstrapError({required this.message});
}
