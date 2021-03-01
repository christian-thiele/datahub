import 'session.dart';

/// Interface for session persistence.
abstract class SessionProvider {

  Future<Session> createSession(int userId);

  /// Finds and returns the session associated with the token and resets
  /// timeout. Throws if timed out or token invalid.
  Future<Session> redeemToken(String sessionToken);

  Future<Session?> findSessionById(String id);

  /// Finds all active user sessions.
  Future<List<Session>> getUserSession(int userId);

  /// Returns all active sessions.
  Future<List<Session>> getActiveSessions();
}