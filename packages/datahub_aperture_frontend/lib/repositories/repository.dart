abstract interface class Repository {
  Future<void> initialize();
  Future<void> close();
}
