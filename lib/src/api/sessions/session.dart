class Session<TId> {
  final String sessionId;
  final String sessionToken;

  final TId userId;
  final DateTime startDate;
  final Map<String, String> data;

  Session(this.sessionId, this.userId, this.startDate, this.sessionToken,
      this.data);

  Duration get duration => DateTime.now().difference(startDate);
}
