part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthStateUnauthorized extends AuthState {}

final class AuthStateLoading extends AuthState {}

final class AuthStateError extends AuthState {
  final String? message;

  AuthStateError({required this.message});
}

final class AuthStateAuthorized extends AuthState {
  AuthStateAuthorized();
}
