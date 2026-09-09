import 'package:datahub/data.dart';
import 'package:test/test.dart';

void main() {
  group('SortGroup.reduce', () {
    List<Sort> cases() {
      final a = Sort.asc('a');
      final b = Sort.desc('b');
      final c = Sort.asc('c');
      const e = Sort.empty;

      return [
        e,
        a,
        const SortGroup([]),
        const SortGroup([e]),
        SortGroup([a]),
        SortGroup([a, e, b]),
        SortGroup([
          SortGroup([a, b]),
          c,
        ]),
        SortGroup([
          a,
          SortGroup([e, b]),
          c,
        ]),
        SortGroup([
          SortGroup([
            SortGroup([a, b]),
            c,
          ]),
          e,
        ]),
      ];
    }

    test('collapses an operand-less group', () {
      expect(_describe(const SortGroup([]).reduce()), _empty);
      expect(_describe(Sort.followedBy([])), _empty);
    });

    test('collapses a group of empty operands', () {
      expect(_describe(const SortGroup([Sort.empty]).reduce()), _empty);
      expect(
        _describe(const SortGroup([Sort.empty, Sort.empty]).reduce()),
        _empty,
      );
    });

    // Regression: a single-operand group used to survive reduction, so
    // `SortGroup([s]).reduce()` disagreed with `Sort.followedBy([s])`.
    test('collapses a single operand', () {
      final a = Sort.asc('a');
      expect(_describe(SortGroup([a]).reduce()), same(a));
      expect(_describe(Sort.followedBy([a])), same(a));

      // A group left with one operand after empties are dropped.
      expect(_describe(SortGroup([Sort.empty, a]).reduce()), same(a));
    });

    test('drops empty operands, preserving order', () {
      final a = Sort.asc('a');
      final b = Sort.desc('b');

      expect(_describe(SortGroup([a, Sort.empty, b]).reduce()), [a, b]);
    });

    // Regression: nested groups used to survive reduction untouched.
    test('flattens nested groups, preserving order', () {
      final a = Sort.asc('a');
      final b = Sort.desc('b');
      final c = Sort.asc('c');
      final d = Sort.desc('d');
      final e = Sort.asc('e');

      expect(
        _describe(
          SortGroup([
            SortGroup([a, b]),
            c,
          ]).reduce(),
        ),
        [a, b, c],
      );

      expect(
        _describe(
          SortGroup([
            a,
            SortGroup([
              b,
              SortGroup([c, d]),
            ]),
            e,
          ]).reduce(),
        ),
        [a, b, c, d, e],
      );
    });

    // Regression: isEmpty was `sorts.isEmpty`, so a group of empty operands
    // reported itself as non-empty even though it orders by nothing.
    test('reports a group of empty operands as empty', () {
      expect(const SortGroup([]).isEmpty, isTrue);
      expect(const SortGroup([Sort.empty]).isEmpty, isTrue);
      expect(SortGroup([Sort.asc('a')]).isEmpty, isFalse);
      expect(SortGroup([Sort.empty, Sort.asc('a')]).isEmpty, isFalse);
    });

    test('is idempotent', () {
      for (final sort in cases()) {
        final once = sort.reduce();
        expect(
          _describe(once.reduce()),
          _describe(once),
          reason: _describe(sort).toString(),
        );
      }
    });

    test('preserves the flat sort key order', () {
      for (final sort in cases()) {
        expect(
          sort.reduce().expand(),
          orderedEquals(sort.expand()),
          reason: _describe(sort).toString(),
        );
      }
    });
  });

  group('Sort.followedBy', () {
    test('agrees with SortGroup.reduce', () {
      final a = Sort.asc('a');
      final b = Sort.desc('b');
      final c = Sort.asc('c');

      for (final operands in [
        <Sort>[],
        [a],
        [Sort.empty],
        [a, b],
        [a, Sort.empty, b],
        [
          SortGroup([a, b]),
          c,
        ],
      ]) {
        expect(
          _describe(Sort.followedBy(operands)),
          _describe(SortGroup(operands).reduce()),
        );
      }
    });

    test('accepts a lazy iterable', () {
      final a = Sort.asc('a');
      final b = Sort.desc('b');

      expect(_describe(Sort.followedBy([a, b].map((e) => e))), [a, b]);
    });
  });
}

const _empty = 'empty';

Object _describe(Sort sort) => switch (sort) {
  EmptySort() => _empty,
  ExpressionSort() => sort,
  SortGroup(:final sorts) => sorts.map(_describe).toList(),
};
