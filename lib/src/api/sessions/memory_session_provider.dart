// TODO RedisSessionProvider or others, bit more documentation i guess
import 'package:boost/boost.dart';
import 'package:cl_datahub/utils.dart';
import 'package:cl_datahub_common/common.dart';

import 'memory_session.dart';
import 'session_provider.dart';

/// [SessionProvider] implementation that stores all session data in memory.
///
/// This is suitable for single-instance services or development purposes.
/// Session data will not be persisted and is gone after restarting the service.
/// [maxDuration] determines how long a session can live between requests.
/// If set to [Duration.zero], sessions will never time out.
class MemorySessionProvider<TUserId> implements SessionProvider<TUserId, MemorySession<TUserId>, TUserId> {
  int _currentId = 1;
  final Duration maxDuration;
  final List<MemorySession<TUserId>> _sessions = [];

  MemorySessionProvider({this.maxDuration = const Duration(minutes: 30)});

  @override
  Future<MemorySession<TUserId>> createSession(TUserId userId) async {
    final sessionId = (_currentId++).toString();
    final sessionToken = Token();
    final session =
        MemorySession(sessionId, userId, DateTime.now(), sessionToken.toString(), {});
    _sessions.add(session);
    return session;
  }

  @override
  Future<MemorySession<TUserId>> redeemToken(String sessionToken) async {
    final current = _sessions
        .firstOrNullWhere((element) => element.sessionToken == sessionToken);

    if (current != null && current.duration > maxDuration) {
      _sessions.remove(current);
      throw ApiException('Session timed out.');
    }

    return current ?? (throw ApiException('Session token not found.'));
  }

  @override
  Future<List<MemorySession<TUserId>>> getActiveSessions() async {
    _sessions.removeWhere((s) => s.duration > maxDuration);
    return List.unmodifiable(_sessions);
  }

  @override
  Future<List<MemorySession<TUserId>>> getUserSession(TUserId userId) async {
    final userSessions = _sessions.where((s) => s.userId == userId).toList();
    for (final session in userSessions) {
      if (session.duration > maxDuration) {
        _sessions.remove(session);
      }
    }

    return List.unmodifiable(_sessions.where((s) => s.userId == userId));
  }
}
