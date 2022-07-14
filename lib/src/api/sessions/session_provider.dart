import 'package:datahub/src/api/sessions/session.dart';

/// Interface for session persistence.
abstract class SessionProvider<TAuthResult, TSession extends Session, TUserId> {
  /// Creates a new session using the result data given by [AuthProvider].
  Future<TSession> createSession(TAuthResult authResult);

  /// Finds and returns the session associated with the token and resets
  /// timeout. Throws if timed out or token invalid.
  Future<TSession> redeemToken(String sessionToken);

  /// Finds all active user sessions.
  Future<List<TSession>> getUserSession(TUserId userId);

  /// Returns all active sessions.
  Future<List<TSession>> getActiveSessions();
}
