import 'dart:math' as math;

import 'exceptions.dart';

extension IterableExtension<E> on Iterable<E> {
  /// Returns a random element.
  E get random {
    if (isEmpty) {
      return first; // supposed to trigger internal noElement exception
    }

    return elementAt(math.Random().nextInt(length));
  }

  /// Returns a subset of this [Iterable] containing every element whose key is
  /// not equal to the key of any previous element.
  ///
  /// If [keySelector] is null, the element itself is considered as key.
  Iterable<E> distinct([Function(E)? keySelector]) sync* {
    final keys = [];
    for (final element in this) {
      final key = (keySelector == null) ? element : keySelector(element);
      if (keys.contains(key)) continue;
      keys.add(key);
      yield element;
    }
  }

  /// Groups elements of this [iterable] by comparing the [selector] result.
  Map<K, List<E>> groupBy<K>(K Function(E) selector) {
    final map = <K, List<E>>{};
    forEach((element) {
      final key = selector(element);
      if (map[key] == null) {
        map[key] = [element];
      } else {
        map[key]!.add(element);
      }
    });
    return map;
  }

  /// Shallow equality check.
  ///
  /// Checks if elements in [other] are equal to the elements in this [Iterable].
  bool sequenceEquals(Iterable other) {
    if (this == other) {
      return true;
    }

    if (other.length != length) {
      return false;
    }

    for (final pair in zip(other)) {
      if (pair.$1 != pair.$2) {
        return false;
      }
    }

    return true;
  }

  /// Deep equality check.
  ///
  /// Checks if elements in [other] are equal to the elements in this [Iterable].
  /// Elements of type [Iterable] and [Map] are compared using the
  /// [Iterable.equalsDeep] and [Map.equalsDeep] extension methods.
  bool equalsDeep(Iterable other) {
    if (this == other) {
      return true;
    }

    if (length != other.length) {
      return false;
    }

    for (final pair in zip(other)) {
      final equal = switch (pair) {
        (final Iterable a, final Iterable b) => a.equalsDeep(b),
        (final Map a, final Map b) => a.equalsDeep(b),
        (final a, final b) => a == b,
      };

      if (!equal) {
        return false;
      }
    }

    return true;
  }

  /// Splits the collection into two subsets.
  ///
  /// Every element for which [selector] returns true is added to the
  /// $1 list, otherwise it is added to the $2 list.
  (List<E>, List<E>) split(bool Function(E) selector) {
    final collections = (<E>[], <E>[]);
    for (final element in this) {
      if (selector(element)) {
        collections.$1.add(element);
      } else {
        collections.$2.add(element);
      }
    }
    return collections;
  }

  /// Merges every element of this [Iterable] with the corresponding element
  /// of [other] into a Tuple.
  ///
  /// If this and [other] have varying lengths, null will be substituted for
  /// the missing counter part in the result Tuple.
  Iterable<(E?, TOther?)> zip<TOther>(Iterable<TOther> other) {
    return Iterable.generate(
      math.max(length, other.length),
      (i) => (
        length > i ? elementAt(i) : null,
        other.length > i ? other.elementAt(i) : null
      ),
    );
  }

  /// Finds the element with the smallest value selected by the selector function.
  ///
  /// All values returned by the selector must be of type num.
  /// If selector is null, the elements itself become the selected elements.
  E min([Function(E)? selector]) {
    selector ??= (e) => e;

    E? minObject;
    num? minValue;

    for (final element in this) {
      final value = selector(element);
      if (value == null) {
        throw BoostException('Selector for element $element returned null!');
      } else if (value is! num) {
        throw BoostException(
            'Selector for element $element did not return num!');
      }

      if (minValue == null || value < minValue) {
        minObject = element;
        minValue = value;
      }
    }

    if (minObject == null) {
      throw BoostException('Iterable is empty.');
    }

    return minObject;
  }

  /// Finds the element with the largest value selected by the selector function.
  ///
  /// All values returned by the selector must be of type num.
  /// If selector is null, the elements itself become the selected elements.
  E max([Function(E)? selector]) {
    selector ??= (e) => e;

    E? maxObject;
    num? maxValue;
    for (final element in this) {
      final value = selector(element);
      if (value == null) {
        throw BoostException('Selector for element $element returned null!');
      } else if (value is! num) {
        throw BoostException(
            'Selector for element $element did not return num!');
      }

      if (maxValue == null || value > maxValue) {
        maxObject = element;
        maxValue = value;
      }
    }

    if (maxObject == null) {
      throw BoostException('Iterable is empty.');
    }

    return maxObject;
  }

  /// Returns an [Iterable] where elements of this are separated by
  /// the [separator] value.
  Iterable<E> separatedBy(E separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return;
    }
    yield iterator.current;

    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }
}

extension ListExtension<E> on List<E> {
  /// Replaces a single element of this [List] with [replacement].
  ///
  /// Removes the first object which is equal to [needle],
  /// then inserts [replacements] at the former index of [needle].
  void replaceItem(E needle, E replacement, [int start = 0]) {
    final idx = indexOf(needle, start);
    if (idx == -1) {
      throw BoostException('Item not found in list.');
    }
    replaceRange(idx, idx + 1, [replacement]);
  }

  /// Sorts this [List] by comparing the keys returned by the [selector].
  void sortBy<K extends Comparable>(K Function(E) selector,
      [bool ascending = true]) {
    sort((a, b) => ascending
        ? Comparable.compare(selector(a), selector(b))
        : Comparable.compare(selector(b), selector(a)));
  }
}

/// Extensions for Iterables of type Tuple.
extension TupleIterableExtension<Ta, Tb> on Iterable<(Ta, Tb)> {
  /// Returns an iterable providing all [Tuple.$1] values.
  Iterable<Ta> get $1 => map((e) => e.$1);

  /// Returns an iterable providing all [Tuple.$2] values.
  Iterable<Tb> get $2 => map((e) => e.$2);
}

/// Extensions for Iterables of type Triple.
extension TripleIterableExtension<Ta, Tb, Tc> on Iterable<(Ta, Tb, Tc)> {
  /// Returns an iterable providing all Triple.$1 values.
  Iterable<Ta> get $1 => map((e) => e.$1);

  /// Returns an iterable providing all Triple.$2 values.
  Iterable<Tb> get $2 => map((e) => e.$2);

  /// Returns an iterable providing all Triple.$3 values.
  Iterable<Tc> get $3 => map((e) => e.$3);
}

extension MapExtension<K, V> on Map<K, V> {
  /// Returns an [Iterable] of all [entries] as (key, value) tuples.
  Iterable<(K, V)> get tuples => entries.map((e) => (e.key, e.value));

  /// Shallow equality check.
  ///
  /// Checks if entries in [other] are equal to the entries in this [Map].
  bool entriesEqual(Map other) {
    if (other.length != length) {
      return false;
    }

    for (final (key, value) in tuples) {
      if (!other.containsKey(key)) {
        return false;
      }
      if (value != other[key]) {
        return false;
      }
    }

    return true;
  }

  /// Deep equality check.
  ///
  /// Checks if entries in [other] are equal to the entries in this [Map].
  bool equalsDeep(Map other) {
    if (length != other.length) {
      return false;
    }

    for (final (key, value) in tuples) {
      if (!other.containsKey(key)) {
        return false;
      }

      final equal = switch ((value, other[key])) {
        (final Iterable a, final Iterable b) => a.equalsDeep(b),
        (final Map a, final Map b) => a.equalsDeep(b),
        (final a, final b) => a == b,
      };

      if (!equal) {
        return false;
      }
    }

    return true;
  }
}
