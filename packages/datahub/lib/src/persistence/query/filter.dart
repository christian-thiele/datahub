import 'expression.dart';

/// Representing filter arguments in a uniform, abstract way.
///
/// To allow different [DatabaseAdapter] implementations to interpret or
/// implement filtering in different ways (e.g. convert to SQL statements)
/// this is a uniform representation of filter arguments.
///
/// All [Filter] implementations are immutable.
abstract class Filter {
  /// Returns the representation of "no filter".
  static const Filter empty = _EmptyFilter();

  const Filter();

  bool get isEmpty;

  /// Tries to simplify the Filter structure to avoid redundancy.
  Filter reduce();

  /// Returns the smallest representation of the "And" group of [filters].
  ///
  /// See implementation of [_optimizedGroup] for details;
  static Filter andGroup(Iterable<Filter> filters) =>
      _optimizedGroup(filters, FilterGroupType.And);

  /// Returns the smallest representation of the "Or" group of [filters].
  ///
  /// See implementation of [_optimizedGroup] for details;
  static Filter orGroup(Iterable<Filter> filters) =>
      _optimizedGroup(filters, FilterGroupType.Or);

  /// Convenience method for creating a [CompareFilter] filter
  /// with compare type [CompareType.equals].
  ///
  /// If any of the parameters is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  static CompareFilter equals(dynamic left, dynamic right) {
    return CompareFilter(Expression.dynamic(left), CompareType.equals,
        Expression.dynamic(right));
  }

  /// Convenience method for creating a [CompareFilter] filter
  /// with compare type [CompareType.notEquals].
  ///
  /// If any of the parameters is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  static CompareFilter notEquals(dynamic left, dynamic right) {
    return CompareFilter(Expression.dynamic(left), CompareType.notEquals,
        Expression.dynamic(right));
  }

  /// Assembles the smallest representation of [filters] combined.
  static Filter _optimizedGroup(
      Iterable<Filter> filters, FilterGroupType type) {
    return FilterGroup(filters.toList(growable: false), type).reduce();
  }
}

extension FilterExtension on Filter {
  Filter and(Filter other) => Filter.andGroup([this, other]);

  Filter or(Filter other) => Filter.orGroup([this, other]);
}

enum FilterGroupType { And, Or }

/// Joins multiple [Filter] elements into a group using a [FilterGroupType].
///
/// Best practice: Use the convenience methods [Filter.and] / [Filter.or]
/// instead of instantiating [FilterGroup] directly.
class FilterGroup extends Filter {
  final List<Filter> filters;
  final FilterGroupType type;

  const FilterGroup(this.filters, this.type);

  @override
  bool get isEmpty => filters.every((element) => element.isEmpty);

  @override
  Filter reduce() {
    final reduced = filters
        .map((f) => f.reduce())
        .where((element) => !element.isEmpty)
        .toList(growable: false);

    if (reduced.isEmpty) {
      return Filter.empty;
    } else if (reduced.length == 1) {
      return reduced.single;
    } else {
      // TODO solve unnecessarily nested groups
      return FilterGroup(reduced, type);
    }
  }
}

enum CompareType {
  equals,
  notEquals,
  contains,
  greaterThan,
  lessThan,
  greaterOrEqual,
  lessOrEqual,
  isIn,
}

class CompareFilter extends Filter {
  final Expression left;
  final CompareType type;
  final Expression right;
  final bool caseSensitive;

  const CompareFilter(this.left, this.type, this.right,
      {this.caseSensitive = true});

  @override
  bool get isEmpty => false;

  @override
  Filter reduce() => this;
}

class _EmptyFilter extends Filter {
  const _EmptyFilter();

  @override
  final bool isEmpty = true;

  @override
  Filter reduce() => this;
}
