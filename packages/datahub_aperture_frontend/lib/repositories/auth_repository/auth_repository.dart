import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture_frontend/repositories/repository.dart';

abstract interface class AuthRepository implements Repository {
  Future<Authentication> signInAuthorizationCode(String code);
  Future<Authentication> refreshAuthentication(String refreshCode);

  Future<void> startAuthorizationCodeFlow();
}
