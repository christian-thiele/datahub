import 'package:bloc/bloc.dart';

import 'auth_cubit.dart';

mixin AuthStrategyMixin on Cubit<AuthState> {
  Future<void> receiveAuthorizationCode(String state, String code);

  Future<void> loginAuthCode() async => throw UnimplementedError();
}
