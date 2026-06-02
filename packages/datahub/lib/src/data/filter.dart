import 'data_field.dart';
import 'data_object.dart';
import 'expression.dart';
import 'sort.dart';

/// Representing filter arguments in a uniform, abstract way.
sealed class Filter {
  static const Filter empty = EmptyFilter();

  const Filter();

  bool get isEmpty;

  /// Evaluates this filter against [object] and returns whether it matches.
  ///
  /// This provides in-memory filter evaluation with semantics matching the
  /// PostgreSQL implementation:
  /// - String `contains`/`isIn` use case-insensitive regex matching
  /// - List `contains` checks element membership
  /// - null comparisons use `== null` / `!= null` semantics
  bool matches(DataObject object);

  Filter and(Filter other) => Filter.andGroup([this, other]);

  Filter or(Filter other) => Filter.orGroup([this, other]);

  /// Tries to simplify the Filter structure to avoid redundancy.
  Filter reduce();

  /// Returns the smallest representation of the "And" group of [filters].
  ///
  /// See implementation of [_optimizedGroup] for details;
  static Filter andGroup(Iterable<Filter> filters) =>
      _optimizedGroup(filters, true);

  /// Returns the smallest representation of the "Or" group of [filters].
  ///
  /// See implementation of [_optimizedGroup] for details;
  static Filter orGroup(Iterable<Filter> filters) =>
      _optimizedGroup(filters, false);

  /// Convenience method for creating a [CompareFilter] filter
  /// with compare type [CompareType.equals].
  ///
  /// If any of the parameters is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  static CompareFilter equals(dynamic left, dynamic right) {
    return CompareFilter(
      Expression.dynamic(left),
      CompareType.equals,
      Expression.dynamic(right),
    );
  }

  /// Convenience method for creating a [CompareFilter] filter
  /// with compare type [CompareType.notEquals].
  ///
  /// If any of the parameters is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  static CompareFilter notEquals(dynamic left, dynamic right) {
    return CompareFilter(
      Expression.dynamic(left),
      CompareType.notEquals,
      Expression.dynamic(right),
    );
  }

  /// Assembles the smallest representation of [filters] combined.
  static Filter _optimizedGroup(Iterable<Filter> filters, bool isConjunction) {
    return FilterGroup(filters.toList(growable: false), isConjunction).reduce();
  }
}

/// Joins multiple [Filter] elements into a group using a [FilterGroupType].
///
/// Best practice: Use the convenience methods [Filter.and] / [Filter.or]
/// instead of instantiating [FilterGroup] directly.
final class FilterGroup extends Filter {
  final List<Filter> filters;
  final bool isConjunction;

  const FilterGroup(this.filters, this.isConjunction);

  @override
  bool matches(DataObject object) => isConjunction
      ? filters.every((f) => f.matches(object))
      : filters.any((f) => f.matches(object));

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
    } else if (isConjunction) {
      final aggregatedConjunctions = reduced
          .map((e) {
            if (e case FilterGroup(:final filters, isConjunction: true)) {
              return filters;
            } else {
              return [e];
            }
          })
          .expand((e) => e)
          .toList();
      return FilterGroup(aggregatedConjunctions, true);
    } else {
      return FilterGroup(reduced, isConjunction);
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

final class CompareFilter extends Filter {
  final Expression left;
  final CompareType type;
  final Expression right;
  final bool caseSensitive;

  const CompareFilter(
    this.left,
    this.type,
    this.right, {
    this.caseSensitive = true,
  });

  @override
  bool matches(DataObject object) {
    final leftVal = _evaluateExpression(object, left);
    final rightVal = _evaluateExpression(object, right);
    return _compare(leftVal, type, rightVal);
  }

  @override
  bool get isEmpty => false;

  @override
  Filter reduce() => this;
}

final class EmptyFilter extends Filter {
  const EmptyFilter();

  @override
  bool matches(DataObject object) => true;

  @override
  final bool isEmpty = true;

  @override
  Filter reduce() => this;
}

dynamic _evaluateExpression(DataObject object, Expression expression) {
  return switch (expression) {
    ValueExpression(:final value) => value,
    final DataField field => field.valueOf(object),
    _ => throw UnsupportedError(
      'Expression of type ${expression.runtimeType} cannot be evaluated.',
    ),
  };
}

bool _compare(dynamic left, CompareType type, dynamic right) {
  // Null handling (matches PostgreSQL IS NULL / IS NOT NULL)
  if (right == null) {
    return switch (type) {
      CompareType.equals => left == null,
      CompareType.notEquals => left != null,
      _ => false,
    };
  }
  if (left == null) {
    return switch (type) {
      CompareType.equals => false,
      CompareType.notEquals => true,
      _ => false,
    };
  }

  // String contains/isIn: case-insensitive regex (matches PostgreSQL ~*)
  if (left is String && right is String) {
    if (type == CompareType.contains) {
      return RegExp(right, caseSensitive: false).hasMatch(left);
    }
    if (type == CompareType.isIn) {
      return RegExp(left, caseSensitive: false).hasMatch(right);
    }
  }

  // List contains: element membership (matches PostgreSQL ANY)
  if (left is List && type == CompareType.contains) {
    return left.contains(right);
  }

  // List isIn: element membership (matches PostgreSQL ANY)
  if (right is List && type == CompareType.isIn) {
    return right.contains(left);
  }

  // DateTime comparisons
  if (left is DateTime && right is DateTime) {
    return switch (type) {
      CompareType.equals ||
      CompareType.contains ||
      CompareType.isIn => left.isAtSameMomentAs(right),
      CompareType.notEquals => !left.isAtSameMomentAs(right),
      CompareType.greaterThan => left.isAfter(right),
      CompareType.lessThan => left.isBefore(right),
      CompareType.greaterOrEqual => !left.isBefore(right),
      CompareType.lessOrEqual => !left.isAfter(right),
    };
  }

  // Default comparisons
  return switch (type) {
    CompareType.equals ||
    CompareType.contains ||
    CompareType.isIn => left == right,
    CompareType.notEquals => left != right,
    CompareType.greaterThan => (left as Comparable).compareTo(right) > 0,
    CompareType.lessThan => (left as Comparable).compareTo(right) < 0,
    CompareType.greaterOrEqual => (left as Comparable).compareTo(right) >= 0,
    CompareType.lessOrEqual => (left as Comparable).compareTo(right) <= 0,
  };
}

extension ExpressionFilterExtension on Expression {
  /// Convenience method for creating a CompareFilter which matches
  /// if this equals [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter equals(dynamic other) =>
      CompareFilter(this, CompareType.equals, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this does not equal [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter notEquals(dynamic other) =>
      CompareFilter(this, CompareType.notEquals, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is greater than [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter greaterThan(dynamic other) =>
      CompareFilter(this, CompareType.greaterThan, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is greater than or equals [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter greaterOrEqual(dynamic other) => CompareFilter(
    this,
    CompareType.greaterOrEqual,
    Expression.dynamic(other),
  );

  /// Convenience method for creating a CompareFilter which matches
  /// if this is less than [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter lessThan(dynamic other) =>
      CompareFilter(this, CompareType.lessThan, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is less than or equals [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter lessOrEqual(dynamic other) =>
      CompareFilter(this, CompareType.lessOrEqual, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this contains [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter contains(dynamic other) =>
      CompareFilter(this, CompareType.contains, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is in [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter isIn(dynamic other) =>
      CompareFilter(this, CompareType.isIn, Expression.dynamic(other));

  /// Creates a [Sort] that orders ascending by this expression.
  Sort asc() => sort(true);

  /// Creates a [Sort] that orders descending by this expression.
  Sort desc() => sort(false);

  /// Creates a [Sort] that orders by this expression.
  Sort sort(bool ascending) => ExpressionSort(this, ascending);
}
