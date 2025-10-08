import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit()
    : super(LoginFormState(username: '', password: '', isValid: false));

  void setUsername(String username) {
    emit(
      LoginFormState(
        username: username,
        password: state.password,
        isValid: _isValid(username, state.password),
      ),
    );
  }

  void setPassword(String password) {
    emit(
      LoginFormState(
        username: state.username,
        password: password,
        isValid: _isValid(state.username, password),
      ),
    );
  }

  static bool _isValid(String username, String password) {
    if (username.length < 3) {
      return false;
    }

    if (password.length < 3) {
      return false;
    }

    return true;
  }
}
