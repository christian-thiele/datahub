import 'package:cl_datahub/cl_datahub.dart';

/// Representing sort arguments in a uniform, abstract way.
///
/// To allow different [DatabaseAdapter] implementations to interpret or
/// implement ordering in different ways (e.g. convert to SQL statements)
/// this is a uniform representation of sort arguments.
abstract class Sort {
  bool get isEmpty;

  const Sort();

  static const Sort empty = _EmptySort();

  /// Convenience method for creating an ascending [ExpressionSort].
  static Sort asc(dynamic expression) =>
      ExpressionSort(Expression.dynamic(expression), true);

  /// Convenience method for creating a descending [ExpressionSort].
  static Sort desc(dynamic expression) =>
      ExpressionSort(Expression.dynamic(expression), false);

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

  /// Returns a linear list of [ExpressionSort].
  List<ExpressionSort> linear();
}

class ExpressionSort extends Sort {
  final Expression expression;
  final bool ascending;

  const ExpressionSort(this.expression, this.ascending);

  @override
  bool get isEmpty => false;

  @override
  Sort reduce() => this;

  @override
  List<ExpressionSort> linear() => [this];
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
  List<ExpressionSort> linear() =>
      sorts.expand((element) => element.linear()).toList();
}

class _EmptySort implements Sort {
  const _EmptySort();

  @override
  final bool isEmpty = true;

  @override
  Sort reduce() => this;

  @override
  List<ExpressionSort> linear() => [];
}
