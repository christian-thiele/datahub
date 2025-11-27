import 'package:bloc/bloc.dart';
import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub_aperture_frontend/services/auth_service.dart';
import 'package:datahub_aperture_frontend/utils/auth_callback_listener.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_cubit.dart';

mixin AuthStrategyMixin on Cubit<AuthState> {
  Future<void> receiveAuthorizationCode(String state, String code);

  Future<void> loginAuthCode() async {
    if (state is! AuthStateLoading) {
      emit(AuthStateLoading());
      try {
        final redirectUri = Uri(
          scheme: 'http',
          host: 'localhost',
          port: 54999,
          path: '/auth/return',
        );

        final url = await AuthService.instance.createAuthUri(
          redirectUri.toString(),
        );

        final cancelListener = CancellationToken();
        final listener = listenForAuthCallback(redirectUri, cancelListener);

        try {
          if (!await launchUrl(url, webOnlyWindowName: '_self')) {
            emit(AuthStateError(message: 'Could not launch sign-in page.'));
          }
        } catch (e) {
          cancelListener.cancel();
          rethrow;
        }

        final result = await listener;
        await receiveAuthorizationCode(result.state, result.code);
      } catch (e) {
        if (e case ApiRequestException(:final message)) {
          emit(AuthStateError(message: message));
        } else {
          emit(AuthStateError(message: null));
        }
      }
    }
  }
}
