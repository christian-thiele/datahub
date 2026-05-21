part of 'bootstrap_cubit.dart';

sealed class BootstrapState {}

final class BootstrapLoading extends BootstrapState {}

final class BootstrapSuccess extends BootstrapState {
  final ApertureBootstrap bootstrap;
  final Uri apiUrl;

  BootstrapSuccess({required this.bootstrap, required this.apiUrl});
}

final class BootstrapError extends BootstrapState {
  final String? message;

  BootstrapError({required this.message});
}
