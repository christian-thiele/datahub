// TODO RedisSessionProvider or others, bit more documentation i guess
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/sessions/session.dart';
import 'package:boost/boost.dart';

import 'session_provider.dart';

/// [SessionProvider] implementation that stores all session data in memory.
///
/// This is suitable for single-instance services or development purposes.
/// Session data will not be persisted and is gone after restarting the service.
/// [maxDuration] determines how long a session can live between requests.
/// If set to [Duration.zero], sessions will never time out.
class MemorySessionProvider implements SessionProvider {
  int _currentId = 1;
  final Duration maxDuration;
  final List<Session> _sessions = [];

  MemorySessionProvider({this.maxDuration = const Duration(minutes: 30)});

  String _generateToken(String sessionid) {
    return sessionid; //TODO!!!! generate uuid!!! this is security shit, don't fucking ditch on int
  }

  @override
  Future<Session> createSession(int userId) async {
    final sessionId = (_currentId++).toString();
    final sessionToken = _generateToken(sessionId);
    final session =
        Session(sessionId, userId, DateTime.now(), sessionToken, {});
    _sessions.add(session);
    return session;
  }

  @override
  Future<Session?> findSessionById(String id) async {
    final current =
        _sessions.firstOrNullWhere((element) => element.sessionId == id);

    if (current != null && current.duration > maxDuration) {
      _sessions.remove(current);
      return null;
    }

    return current;
  }

  @override
  Future<Session> redeemToken(String sessionToken) async {
    final current =
    _sessions.firstOrNullWhere((element) => element.sessionToken == sessionToken);

    if (current != null && current.duration > maxDuration) {
      _sessions.remove(current);
      throw ApiException('Session timed out.');
    }

    return current ?? (throw ApiException('Session token not found.'));
  }

  @override
  Future<List<Session>> getActiveSessions() async {
    _sessions.removeWhere((s) => s.duration > maxDuration);
    return List.unmodifiable(_sessions);
  }

  @override
  Future<List<Session>> getUserSession(int userId) async {
    final userSessions = _sessions.where((s) => s.userId == userId).toList();
    for (final session in userSessions) {
      if(session.duration > maxDuration) {
        _sessions.remove(session);
      }
    }

    return List.unmodifiable(_sessions.where((s) => s.userId == userId));
  }
}
