/// Representing sort arguments in a uniform, abstract way.
///
/// To allow different [DatabaseAdapter] implementations to interpret or
/// implement ordering in different ways (e.g. convert to SQL statements)
/// this is a uniform representation of sort arguments.
abstract class Sort {
  bool get isEmpty;

  const Sort();

  static const Sort empty = _EmptySort();

  /// Convenience method for creating an ascending [PropertySort].
  static Sort asc(String propertyName) => PropertySort(propertyName, true);

  /// Convenience method for creating a descending [PropertySort].
  static Sort desc(String propertyName) => PropertySort(propertyName, false);

  static Sort followedBy(Iterable<Sort> sorts) {
    final notEmpty =
        sorts.map((e) => e.reduce()).where((element) => !element.isEmpty);
    if (notEmpty.isEmpty) {
      return Sort.empty;
    } else if (notEmpty.length == 1) {
      return notEmpty.single;
    } else {
      return SortGroup(notEmpty.toList(growable: false));
    }
  }

  /// Tries to simplify the Sort structure to avoid redundancy.
  Sort reduce();

  /// Returns a linear list of [PropertySorts].
  List<PropertySort> linear();
}

class PropertySort extends Sort {
  final String propertyName;
  final bool ascending;

  const PropertySort(this.propertyName, this.ascending);

  @override
  bool get isEmpty => false;

  @override
  Sort reduce() => this;

  @override
  List<PropertySort> linear() => [this];
}

class SortGroup extends Sort {
  final List<Sort> sorts;

  const SortGroup(this.sorts);

  @override
  Sort reduce() {
    final reducedSorts = sorts
        .map((e) => e.reduce())
        .where((element) => !element.isEmpty)
        .toList(growable: false);

    if (reducedSorts.isEmpty) {
      return Sort.empty;
    }

    return SortGroup(reducedSorts);
  }

  @override
  bool get isEmpty => sorts.isEmpty;

  @override
  List<PropertySort> linear() =>
      sorts.expand((element) => element.linear()).toList();
}

class _EmptySort implements Sort {
  const _EmptySort();

  @override
  final bool isEmpty = true;

  @override
  Sort reduce() => this;

  @override
  List<PropertySort> linear() => [];
}
