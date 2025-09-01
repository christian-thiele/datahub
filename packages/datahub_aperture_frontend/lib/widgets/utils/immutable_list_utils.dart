extension ImmutableListUtils<T> on Iterable<T> {
  List<T> copyWithInserted(int index, T value) =>
      List.unmodifiable([...take(index), value, ...skip(index)]);

  List<T> copyWithAdded(T value) => [...this, value];

  List<T> copyWithReplaced(int index, T value) =>
      List.unmodifiable([...take(index), value, ...skip(index + 1)]);

  List<T> copyWithRemoved(int index) =>
      List.unmodifiable([...take(index), ...skip(index + 1)]);
}
