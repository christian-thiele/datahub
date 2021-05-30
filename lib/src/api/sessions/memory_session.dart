import 'session.dart';

class MemorySession<TId> implements Session {
  final String sessionId;
  @override
  final String sessionToken;

  final TId userId;
  final DateTime startDate;
  final Map<String, String> data;

  MemorySession(this.sessionId, this.userId, this.startDate, this.sessionToken,
      this.data);

  Duration get duration => DateTime.now().difference(startDate);
}
