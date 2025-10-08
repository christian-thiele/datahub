part of 'login_form_cubit.dart';

class LoginFormState {
  final String username;
  final String password;
  final bool isValid;

  const LoginFormState({
    required this.username,
    required this.password,
    required this.isValid,
  });
}
