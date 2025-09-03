abstract interface class Repository {
  Future<void> initialize() async {}

  Future<void> close() async {}
}
