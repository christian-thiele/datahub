import 'session.dart';

/// Interface for session persistence.
abstract class SessionProvider<TId> {

  Future<Session> createSession(TId userId);

  /// Finds and returns the session associated with the token and resets
  /// timeout. Throws if timed out or token invalid.
  Future<Session> redeemToken(String sessionToken);

  Future<Session?> findSessionById(String id);

  /// Finds all active user sessions.
  Future<List<Session>> getUserSession(TId userId);

  /// Returns all active sessions.
  Future<List<Session>> getActiveSessions();
}