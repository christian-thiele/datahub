import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture_frontend/repositories/auth_repository/auth_repository.dart';
import 'package:datahub_aperture_frontend/repositories/storage_repository/storage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final StorageRepository _storageRepository;
  final AuthRepository _authRepository;

  AuthCubit(this._storageRepository, this._authRepository)
    : super(AuthStateLoading()) {
    _init();
  }

  Future<void> _init() async {
    final storedAuth = await _storageRepository.getStoredAuthentication();
    if (storedAuth?.isValid ?? false) {
      final auth = await _authRepository.refreshAuthentication(
        storedAuth!.refreshToken,
      );
      emit(AuthStateAuthorized(auth: auth));
    } else {
      emit(AuthStateUnauthorized());
    }
  }

  Future<void> login() async {
    if (state is! AuthStateLoading) {
      await _authRepository.startAuthorizationCodeFlow();
    }
  }

  Future<void> receiveAuthorizationCode(String code) async {
    if (state is! AuthStateLoading) {
      emit(AuthStateLoading());
      try {
        final auth = await _authRepository.signInAuthorizationCode(code);
        _storageRepository.storeAuthentication(auth);
        emit(AuthStateAuthorized(auth: auth));
      } catch (e) {
        _storageRepository.clear();
        emit(AuthStateUnauthorized());
      }
    }
  }

  Future<void> logout() async {
    if (state is! AuthStateLoading) {
      _storageRepository.clear();
      emit(AuthStateUnauthorized());
    }
  }
}
