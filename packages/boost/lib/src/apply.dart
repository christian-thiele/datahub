extension Apply<T> on T {
  /// Calls [delegate] with this as argument.
  ///
  /// This is useful when used together with the guard access operator
  /// to only process this value if not null.
  /// Example:
  ///
  /// ```
  /// String? base64 = null;
  /// Uint8List? decoded = base64?.apply(base64Decode);
  /// ```
  Result apply<Result>(Result Function(T) delegate) => delegate(this);
}
