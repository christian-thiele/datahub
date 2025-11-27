import 'package:bloc/bloc.dart';
import 'package:datahub/api.dart';
import 'package:datahub_aperture_frontend/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_cubit.dart';

mixin AuthStrategyMixin on Cubit<AuthState> {
  Future<void> receiveAuthorizationCode(String state, String code);

  Future<void> loginAuthCode() async {
    if (state is! AuthStateLoading) {
      emit(AuthStateLoading());
      try {
        final url = await AuthService.instance.createAuthUri(
          Uri.base.toString(),
        );

        if (!await launchUrl(url, webOnlyWindowName: '_self')) {
          emit(AuthStateError(message: 'Could not launch sign-in page.'));
        }
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
