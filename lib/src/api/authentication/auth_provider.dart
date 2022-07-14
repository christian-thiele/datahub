import 'package:datahub/api.dart';

abstract class AuthProvider<TAuthResult extends AuthResult> {
  /// Authenticates user with given authData from json request.
  ///
  /// Returns auth result if authentication was successful, should throw
  /// [ApiRequestException] otherwise.
  ///
  /// Best practice is to throw [ApiRequestException.unauthorized] on
  /// invalid credential data, [ApiRequestException.badRequest] on missing
  /// credential data and [ApiRequestException.internalError] on internal
  /// errors.
  Future<TAuthResult> authenticate(Map<String, dynamic> authData);
}
