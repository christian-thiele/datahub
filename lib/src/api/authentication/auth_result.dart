/// Provides information about the authentication result.
///
/// See [AuthProvider] and [AuthEndpoint] for details.
abstract class AuthResult {
  /// Data supposed to be returned to the client when authentication was successful.
  ///
  /// Keep in mind that key 'session-token' is occupied by the session token. (duh...)
  Map<String, dynamic> get clientData => const {};
}
