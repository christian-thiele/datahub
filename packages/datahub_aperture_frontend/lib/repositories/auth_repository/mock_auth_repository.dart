import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture_frontend/repositories/auth_repository/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Authentication> refreshAuthentication(String refreshCode) async {
    //await Future.delayed(const Duration(seconds: 1));
    if (refreshCode == 'invalid') {
      throw Exception('Invalid code!');
    }

    return Authentication(
      accessToken: 'accessToken',
      refreshToken: 'refreshToken',
      expiration: DateTime.now().add(Duration(hours: 1)),
    );
  }

  @override
  Future<Authentication> signInAuthorizationCode(String code) async {
    //await Future.delayed(const Duration(seconds: 1));
    if (code == 'invalid') {
      throw Exception('Invalid code!');
    }

    return Authentication(
      accessToken: 'accessToken',
      refreshToken: 'refreshToken',
      expiration: DateTime.now().add(Duration(hours: 1)),
    );
  }

  @override
  Future<void> startAuthorizationCodeFlow() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> initialize() async {}
}
