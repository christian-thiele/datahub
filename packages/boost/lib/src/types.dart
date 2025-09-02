/// A utility class for checking type parameters.
class TypeCheck<T> {
  const TypeCheck();

  /// Returns the name of the [T].
  String get name => T.toString();

  /// Returns the dart Type.
  Type get type => T;

  /// Checks if [T] is nullable.
  ///
  /// [Void], [dynamic] and [Null] will always return true.
  bool get isNullable => isSupertypeOf<T?>();

  /// Checks if [T] is a [List] of any type.
  ///
  /// See [isSubtypeOf] for further info.
  bool get isList => isSubtypeOf<List>();

  /// Checks if [T] is an [Iterable] of any type.
  ///
  /// See [isSubtypeOf] for further info.
  bool get isIterable => isSubtypeOf<Iterable>();

  /// Checks if [T] is a [Map] of any type.
  ///
  /// See [isSubtypeOf] for further info.
  bool get isMap => isSubtypeOf<Map>();

  /// Checks if [T] is a [List] of type `List<E>`.
  bool isListOf<E>() => isSubtypeOf<List<E>>();

  /// Checks if [T] is a [List] of type `Map<K, V>`.
  bool isMapOf<K, V>() => isSubtypeOf<Map<K, V>>();

  /// Returns a [TypeCheck] object for type `List<T>`.
  ///
  /// If [T] is nullable the type parameter for [List] will
  /// also be nullable.
  TypeCheck<List<T>> get toList => TypeCheck<List<T>>();

  /// Returns a [TypeCheck] object for type `Iterable<T>`.
  ///
  /// If [T] is nullable the type parameter for [Iterable] will
  /// also be nullable.
  TypeCheck<Iterable<T>> get toIterable => TypeCheck<Iterable<T>>();

  /// Returns a [TypeCheck] object for type `T?`.
  ///
  /// If [T] is nullable, the result will be the same as this.
  TypeCheck<T?> get toNullable => TypeCheck<T?>();

  /// Returns true if [TOther] is exactly [T].
  bool isExact<TOther>() => T == TOther;

  /// Returns true if instance of [T] is applicable to [TSuper],
  /// as if you would check `new T() is TSuper`.
  ///
  /// WARNING:
  /// `isSubtypeOf<T, void>()`
  /// will always return true, since void is dynamic at runtime.
  ///
  /// To check if T is void, use:
  /// `TypeCheck<void>().isSubtypeOf<T>()`
  /// which does not work for dynamic (as stated above).
  bool isSubtypeOf<TSuper>() {
    return this is TypeCheck<TSuper>;
  }

  /// Returns true if instance of [TSub] is applicable to [T],
  /// as if you would check `new TSub() is T`.
  ///
  /// Also returns true if [T] == [TSub].
  ///
  /// WARNING:
  /// `isSupertypeOf<T, void>()`
  /// will always return true, since void is dynamic at runtime.
  ///
  /// To check if T is void, use:
  /// `isSubtypeOf<void, T>()`
  /// which does not work for dynamic (as stated above).
  bool isSupertypeOf<TSub>() {
    return TypeCheck<TSub>() is TypeCheck<T>;
  }

  /// Returns true if [value] is applicable to [T],
  /// as if you would check `value is T`.
  bool accepts(dynamic value) => value is T;

  @override
  int get hashCode => T.hashCode;

  @override
  bool operator ==(Object other) => other is TypeCheck && other.isExact<T>();

  @override
  String toString() => 'TypeCheck<$name>()';
}
