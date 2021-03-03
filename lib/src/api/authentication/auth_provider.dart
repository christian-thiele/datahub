import 'package:cl_datahub/api.dart';

abstract class AuthProvider {
  /// Authenticates user with given authData from json request.
  ///
  /// Returns userId if authentication was successful, should throw
  /// [ApiRequestException] otherwise.
  ///
  /// Best practice is to throw [ApiRequestException.unauthorized] on
  /// invalid credential data, [ApiRequestException.badRequest] on missing
  /// credential data and [ApiRequestException.internalError] on internal
  /// errors.
  Future<int> authenticate(Map<String, dynamic> authData);
}