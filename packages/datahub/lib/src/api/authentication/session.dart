abstract class Session {
  /// Timestamp of the start of this session.
  DateTime get timestamp;

  /// Emits an event as soon as this session expires.
  Stream<void> get expiration;
}
