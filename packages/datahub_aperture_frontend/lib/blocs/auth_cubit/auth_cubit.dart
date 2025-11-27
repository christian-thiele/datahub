import 'package:datahub/api.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:bloc/bloc.dart';
import 'package:datahub_aperture_frontend/services.dart';

import 'auth_strategy_mixin_web.dart'
    if (dart.library.io) 'auth_strategy_mixin_io.dart'
    if (dart.library.js_interop) 'auth_strategy_mixin_web.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> with AuthStrategyMixin {
  AuthCubit({required ApertureBootstrap bootstrap})
    : super(AuthStateLoading()) {
    _init(bootstrap);
  }

  Future<void> _init(ApertureBootstrap bootstrap) async {
    AuthService.instance.stream.listen(_onAuthServiceUpdated);
    await AuthService.instance.initialize(
      Uri.parse(bootstrap.oidcIssuer),
      clientId: bootstrap.oidcClientId,
      clientSecret: bootstrap.oidcClientSecret,
    );
  }

  void _onAuthServiceUpdated(bool authenticated) async {
    if (authenticated && state is! AuthStateAuthorized) {
      emit(AuthStateAuthorized());
    }
    if (!authenticated &&
        (state is AuthStateAuthorized ||
            state is AuthStateLoading ||
            state is AuthStateUnauthorized)) {
      emit(AuthStateUnauthorized());
    }
  }

  @override
  Future<void> receiveAuthorizationCode(String state, String code) async {
    emit(AuthStateLoading());
    try {
      await AuthService.instance.signInAuthorizationCode(state, code);
    } catch (e) {
      if (e case ApiRequestException(:final message)) {
        emit(AuthStateError(message: message));
      } else {
        emit(AuthStateError(message: null));
      }
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.instance.signOut();
    } catch (e) {
      emit(AuthStateError(message: null));
    }
  }
}
