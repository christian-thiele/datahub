import 'expression.dart';

/// Representing sort arguments in a uniform, abstract way.
sealed class Sort {
  bool get isEmpty;

  const Sort();

  static const Sort empty = EmptySort();

  /// Convenience method for creating an ascending [ExpressionSort].
  static Sort asc(dynamic expression) =>
      ExpressionSort(Expression.dynamic(expression), true);

  /// Convenience method for creating a descending [ExpressionSort].
  static Sort desc(dynamic expression) =>
      ExpressionSort(Expression.dynamic(expression), false);

  /// Returns the smallest representation of [sorts] applied in order.
  static Sort followedBy(Iterable<Sort> sorts) =>
      SortGroup(sorts.toList(growable: false)).reduce();

  /// Returns the smallest representation of this sort that orders by the
  /// same keys, in the same order.
  ///
  /// The result contains no empty operands, no [SortGroup] nested inside
  /// another [SortGroup], and no [SortGroup] with fewer than two operands.
  Sort reduce();

  /// Returns a flat list of [ExpressionSort].
  List<ExpressionSort> expand();
}

final class ExpressionSort extends Sort {
  final Expression expression;
  final bool ascending;

  const ExpressionSort(this.expression, this.ascending);

  @override
  bool get isEmpty => false;

  @override
  Sort reduce() => this;

  @override
  List<ExpressionSort> expand() => [this];
}

final class SortGroup extends Sort {
  final List<Sort> sorts;

  const SortGroup(this.sorts);

  @override
  Sort reduce() {
    // Sort keys are order sensitive, so flattening must preserve their order.
    final reduced = sorts
        .map((e) => e.reduce())
        .where((element) => !element.isEmpty)
        .expand((element) => element is SortGroup ? element.sorts : [element])
        .toList(growable: false);

    return switch (reduced.length) {
      0 => Sort.empty,
      1 => reduced.single,
      _ => SortGroup(reduced),
    };
  }

  @override
  bool get isEmpty => sorts.every((element) => element.isEmpty);

  @override
  List<ExpressionSort> expand() =>
      sorts.expand((element) => element.expand()).toList();
}

final class EmptySort extends Sort {
  const EmptySort();

  @override
  bool get isEmpty => true;

  @override
  Sort reduce() => this;

  @override
  List<ExpressionSort> expand() => [];
}
