part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthStateUnauthorized extends AuthState {}

final class AuthStateLoading extends AuthStateUnauthorized {}

final class AuthStateAuthorized extends AuthState {
  final Authentication auth;

  AuthStateAuthorized({required this.auth});
}
