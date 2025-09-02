class CanceledException implements Exception {
  @override
  String toString() => 'The task has been canceled.';
}
