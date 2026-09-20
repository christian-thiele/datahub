import 'package:datahub/data.dart';
import 'package:test/test.dart';

/// A minimal DataObject for testing filter evaluation.
class Person with DataObject<Person> {
  final String name;
  final int age;
  final String? email;
  final DateTime createdAt;
  final List<String> tags;

  const Person({
    required this.name,
    required this.age,
    this.email,
    required this.createdAt,
    this.tags = const [],
  });

  static final $name = DataField<Person, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (v, {String? name}) => v as String,
    toJson: (v) => v,
  );

  static final $age = DataField<Person, int>(
    name: 'age',
    valueOf: (p) => p.age,
    fromJson: (v, {String? name}) => v as int,
    toJson: (v) => v,
  );

  static final $email = DataField<Person, String?>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (v, {String? name}) => v as String?,
    toJson: (v) => v,
  );

  static final $createdAt = DataField<Person, DateTime>(
    name: 'createdAt',
    valueOf: (p) => p.createdAt,
    fromJson: (v, {String? name}) => DateTime.parse(v as String),
    toJson: (v) => v.toIso8601String(),
  );

  static final $tags = DataField<Person, List<String>>(
    name: 'tags',
    valueOf: (p) => p.tags,
    fromJson: (v, {String? name}) => (v as List).cast<String>(),
    toJson: (v) => v,
  );

  @override
  String get $$name => 'Person';

  @override
  List<DataField<Person, dynamic>> get $$fields => [
    $name,
    $age,
    $email,
    $createdAt,
    $tags,
  ];

  @override
  Map<String, dynamic> toJson() => {
    'name': $name.toJson(name),
    'age': $age.toJson(age),
    'email': $email.toJson(email),
    'createdAt': $createdAt.toJson(createdAt),
    'tags': $tags.toJson(tags),
  };
}

void main() {
  final now = DateTime.utc(2025, 6, 1, 12, 0);
  final earlier = DateTime.utc(2025, 1, 1);
  final later = DateTime.utc(2025, 12, 31);

  final alice = Person(
    name: 'Alice',
    age: 30,
    email: 'alice@example.com',
    createdAt: now,
    tags: ['admin', 'user'],
  );

  final bob = Person(
    name: 'Bob',
    age: 25,
    email: null,
    createdAt: earlier,
    tags: ['user'],
  );

  final charlie = Person(name: 'Charlie', age: 35, createdAt: later, tags: []);

  group('EmptyFilter', () {
    test('matches everything', () {
      expect(Filter.empty.matches(alice), isTrue);
      expect(Filter.empty.matches(bob), isTrue);
    });
  });

  group('NothingFilter', () {
    test('matches nothing', () {
      expect(Filter.nothing.matches(alice), isFalse);
      expect(Filter.nothing.matches(bob), isFalse);
    });

    test('is not empty', () {
      expect(Filter.nothing.isEmpty, isFalse);
    });

    test('reports isNothing through groups', () {
      final a = Person.$name.equals('Alice');

      expect(Filter.nothing.isNothing, isTrue);
      expect(Filter.empty.isNothing, isFalse);
      expect(a.isNothing, isFalse);

      // An unsatisfiable operand absorbs a conjunction.
      expect(FilterGroup([a, Filter.nothing], true).isNothing, isTrue);
      expect(FilterGroup([a, Filter.empty], true).isNothing, isFalse);

      // A disjunction is unsatisfiable only if every operand is.
      expect(FilterGroup([a, Filter.nothing], false).isNothing, isFalse);
      expect(
        const FilterGroup([Filter.nothing, Filter.nothing], false).isNothing,
        isTrue,
      );

      // An operand-less group is unconstrained, not unsatisfiable.
      expect(const FilterGroup([], true).isNothing, isFalse);
      expect(const FilterGroup([], false).isNothing, isFalse);

      // Nesting is resolved at every depth.
      expect(
        FilterGroup([
          FilterGroup([Filter.nothing, a], true),
          FilterGroup([Filter.nothing, Filter.nothing], false),
        ], false).isNothing,
        isTrue,
      );
    });

    test('agrees with matches and reduce for every case', () {
      for (final filter in [
        Filter.nothing,
        Filter.empty,
        Person.$name.equals('Alice'),
        FilterGroup([Person.$name.equals('Alice'), Filter.nothing], true),
        FilterGroup([Person.$name.equals('Alice'), Filter.nothing], false),
        const FilterGroup([Filter.nothing, Filter.nothing], false),
        const FilterGroup([], true),
        const FilterGroup([], false),
      ]) {
        final describe = _describe(filter).toString();

        // isNothing is exactly "matches no object" ...
        if (filter.isNothing) {
          for (final person in [alice, bob, charlie]) {
            expect(filter.matches(person), isFalse, reason: describe);
          }
        }

        // ... and the structural check agrees with reduction.
        expect(
          filter.isNothing,
          filter.reduce() is NothingFilter,
          reason: describe,
        );
      }
    });

    test('combines with and / or', () {
      final byName = Person.$name.equals('Alice');

      expect(byName.and(Filter.nothing).matches(alice), isFalse);
      expect(byName.or(Filter.nothing).matches(alice), isTrue);
      expect(byName.or(Filter.nothing).matches(bob), isFalse);
    });
  });

  group('CompareFilter equals', () {
    test('string equality', () {
      final filter = Person.$name.equals('Alice');
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('int equality', () {
      final filter = Person.$age.equals(30);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('null equality', () {
      final filter = Person.$email.equals(null);
      expect(filter.matches(alice), isFalse);
      expect(filter.matches(bob), isTrue);
    });
  });

  group('CompareFilter notEquals', () {
    test('string not equals', () {
      final filter = Person.$name.notEquals('Alice');
      expect(filter.matches(alice), isFalse);
      expect(filter.matches(bob), isTrue);
    });

    test('null not equals (IS NOT NULL)', () {
      final filter = Person.$email.notEquals(null);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });
  });

  group('CompareFilter ordering', () {
    test('greaterThan int', () {
      final filter = Person.$age.greaterThan(28);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('lessThan int', () {
      final filter = Person.$age.lessThan(28);
      expect(filter.matches(alice), isFalse);
      expect(filter.matches(bob), isTrue);
    });

    test('greaterOrEqual int', () {
      final filter = Person.$age.greaterOrEqual(30);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('lessOrEqual int', () {
      final filter = Person.$age.lessOrEqual(30);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(charlie), isFalse);
    });

    test('greaterThan DateTime', () {
      final filter = Person.$createdAt.greaterThan(now);
      expect(filter.matches(alice), isFalse);
      expect(filter.matches(charlie), isTrue);
    });

    test('lessThan DateTime', () {
      final filter = Person.$createdAt.lessThan(now);
      expect(filter.matches(bob), isTrue);
      expect(filter.matches(alice), isFalse);
    });

    test('greaterOrEqual DateTime (same moment)', () {
      final filter = Person.$createdAt.greaterOrEqual(now);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('lessOrEqual DateTime (same moment)', () {
      final filter = Person.$createdAt.lessOrEqual(now);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(charlie), isFalse);
    });
  });

  group('CompareFilter contains (string)', () {
    test('case-insensitive regex match', () {
      final filter = Person.$name.contains('ali');
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('case-insensitive with uppercase pattern', () {
      final filter = Person.$name.contains('ALICE');
      expect(filter.matches(alice), isTrue);
    });

    test('regex pattern', () {
      final filter = Person.$name.contains('^[AB]');
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isTrue);
      expect(filter.matches(charlie), isFalse);
    });
  });

  group('CompareFilter isIn (string)', () {
    test('case-insensitive reverse regex', () {
      final filter = Person.$name.isIn('alice|bob');
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isTrue);
      expect(filter.matches(charlie), isFalse);
    });
  });

  group('CompareFilter contains (List)', () {
    test('list contains element', () {
      final filter = Person.$tags.contains('admin');
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('list contains common element', () {
      final filter = Person.$tags.contains('user');
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isTrue);
      expect(filter.matches(charlie), isFalse);
    });
  });

  group('CompareFilter isIn (List)', () {
    test('value is in list', () {
      final filter = Person.$name.isIn(['Alice', 'Bob']);
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isTrue);
      expect(filter.matches(charlie), isFalse);
    });
  });

  group('FilterGroup', () {
    test('AND group', () {
      final filter = Person.$name.equals('Alice').and(Person.$age.equals(30));
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isFalse);
    });

    test('AND group with one failing', () {
      final filter = Person.$name.equals('Alice').and(Person.$age.equals(99));
      expect(filter.matches(alice), isFalse);
    });

    test('OR group', () {
      final filter = Person.$name
          .equals('Alice')
          .or(Person.$name.equals('Bob'));
      expect(filter.matches(alice), isTrue);
      expect(filter.matches(bob), isTrue);
      expect(filter.matches(charlie), isFalse);
    });

    test('nested groups', () {
      final filter = (Person.$age.greaterThan(28).and(Person.$age.lessThan(32)))
          .or(Person.$name.equals('Charlie'));
      expect(filter.matches(alice), isTrue); // age 30
      expect(filter.matches(bob), isFalse); // age 25
      expect(filter.matches(charlie), isTrue); // name match
    });
  });

  group('null comparison edge cases', () {
    test('greaterThan with null field returns false', () {
      final filter = Person.$email.greaterThan('a');
      expect(filter.matches(bob), isFalse); // email is null
    });

    test('lessThan with null field returns false', () {
      final filter = Person.$email.lessThan('z');
      expect(filter.matches(bob), isFalse);
    });
  });

  group('FilterGroup.reduce', () {
    // Leaves that always / never match [alice]. Each call returns a distinct
    // instance, so reduced trees can be compared by leaf identity.
    Filter hit() => Person.$age.greaterThan(20);
    Filter miss() => Person.$age.greaterThan(100);

    /// Unreduced trees covering every branch of [FilterGroup.reduce], built
    /// with the [FilterGroup] constructor directly because [Filter.andGroup]
    /// and [Filter.orGroup] already reduce.
    List<Filter> cases() {
      final t = hit();
      final f = miss();
      const e = Filter.empty;
      const n = Filter.nothing;

      return [
        e,
        t,
        f,
        n,
        const FilterGroup([n], true),
        const FilterGroup([n], false),
        const FilterGroup([n, n], false),
        const FilterGroup([e, n], true),
        const FilterGroup([e, n], false),
        FilterGroup([n, t], true),
        FilterGroup([n, t], false),
        FilterGroup([n, f], false),
        FilterGroup([
          FilterGroup([n, t], true),
          t,
        ], false),
        FilterGroup([
          FilterGroup([n, n], false),
          t,
        ], true),
        FilterGroup([
          FilterGroup([n, t], false),
          FilterGroup([n, f], false),
        ], false),
        const FilterGroup([], true),
        const FilterGroup([], false),
        const FilterGroup([e], true),
        const FilterGroup([e], false),
        FilterGroup([e, t], true),
        FilterGroup([e, f], true),
        FilterGroup([e, t], false),
        FilterGroup([e, f], false),
        FilterGroup([t, f], true),
        FilterGroup([t, f], false),
        FilterGroup([
          FilterGroup([t, f], false),
          f,
        ], true),
        FilterGroup([
          FilterGroup([t, f], true),
          t,
        ], false),
        FilterGroup([
          FilterGroup([e, f], false),
          t,
        ], true),
        FilterGroup([
          FilterGroup([
            FilterGroup([t, t], true),
            f,
          ], true),
          t,
        ], true),
      ];
    }

    test('collapses an operand-less group', () {
      expect(_describe(Filter.andGroup([])), _empty);
      expect(_describe(Filter.orGroup([])), _empty);
      expect(_describe(const FilterGroup([], true).reduce()), _empty);
      expect(_describe(const FilterGroup([], false).reduce()), _empty);
    });

    test('collapses a single operand', () {
      final a = hit();
      expect(_describe(Filter.andGroup([a])), same(a));
      expect(_describe(Filter.orGroup([a])), same(a));

      // A group left with one operand after empties are dropped.
      expect(
        _describe(Filter.andGroup([Filter.empty, a, Filter.empty])),
        same(a),
      );
    });

    test('drops empty operands from a conjunction', () {
      final a = hit();
      final b = hit();

      // `a && true == a`, so empty operands are neutral here.
      expect(_describe(Filter.andGroup([Filter.empty, a, b])), ['and', a, b]);
      expect(_describe(a.and(Filter.empty)), same(a));
    });

    // Regression: an empty operand used to be dropped from a disjunction too,
    // which narrowed the result set instead of leaving it unconstrained.
    test('absorbs empty operands into a disjunction', () {
      final a = hit();
      final b = hit();

      // `a || true == true`, so the whole disjunction is unconstrained.
      expect(_describe(Filter.orGroup([Filter.empty, a])), _empty);
      expect(_describe(Filter.orGroup([a, b, Filter.empty])), _empty);
      expect(_describe(a.or(Filter.empty)), _empty);

      // Including when an operand only becomes empty through reduction.
      expect(
        _describe(
          Filter.orGroup([
            a,
            FilterGroup([Filter.empty, b], false),
          ]),
        ),
        _empty,
      );
    });

    test('absorbs nothing operands into a conjunction', () {
      final a = hit();
      final b = hit();

      // `a && false == false`, so the whole conjunction matches nothing.
      expect(_describe(Filter.andGroup([Filter.nothing, a])), _nothing);
      expect(_describe(Filter.andGroup([a, b, Filter.nothing])), _nothing);
      expect(_describe(a.and(Filter.nothing)), _nothing);

      // Nothing wins over empty in a conjunction: `true && false == false`.
      expect(
        _describe(Filter.andGroup([Filter.empty, Filter.nothing])),
        _nothing,
      );

      // Including when an operand only becomes nothing through reduction.
      expect(
        _describe(
          Filter.andGroup([
            a,
            FilterGroup([Filter.nothing, b], true),
          ]),
        ),
        _nothing,
      );
    });

    test('drops nothing operands from a disjunction', () {
      final a = hit();
      final b = hit();

      // `a || false == a`, so nothing operands are neutral here.
      expect(_describe(Filter.orGroup([Filter.nothing, a, b])), ['or', a, b]);
      expect(_describe(a.or(Filter.nothing)), same(a));

      // Empty wins over nothing in a disjunction: `true || false == true`.
      expect(_describe(Filter.orGroup([Filter.empty, Filter.nothing])), _empty);
    });

    // Dropping every nothing operand must not leave an operand-less
    // disjunction behind, which would be unconstrained instead of unsatisfiable.
    test('keeps a disjunction of only nothing operands unsatisfiable', () {
      expect(_describe(Filter.orGroup([Filter.nothing])), _nothing);
      expect(
        _describe(Filter.orGroup([Filter.nothing, Filter.nothing])),
        _nothing,
      );
      expect(
        _describe(
          Filter.orGroup([
            Filter.nothing,
            Filter.andGroup([hit(), Filter.nothing]),
          ]),
        ),
        _nothing,
      );

      // An operand-less disjunction stays unconstrained.
      expect(_describe(Filter.orGroup([])), _empty);
    });

    test('flattens nested conjunctions', () {
      final a = hit();
      final b = hit();
      final c = hit();

      expect(
        _describe(
          Filter.andGroup([
            Filter.andGroup([a, b]),
            c,
          ]),
        ),
        ['and', a, b, c],
      );
      expect(
        _describe(
          Filter.andGroup([
            a,
            Filter.andGroup([b, c]),
          ]),
        ),
        ['and', a, b, c],
      );
    });

    // Regression: only conjunctions used to be flattened, so a disjunction of
    // disjunctions stayed nested forever.
    test('flattens nested disjunctions', () {
      final a = hit();
      final b = hit();
      final c = hit();

      expect(
        _describe(
          Filter.orGroup([
            Filter.orGroup([a, b]),
            c,
          ]),
        ),
        ['or', a, b, c],
      );
      expect(
        _describe(
          Filter.orGroup([
            a,
            Filter.orGroup([b, c]),
          ]),
        ),
        ['or', a, b, c],
      );
    });

    test('keeps groups of mixed polarity nested', () {
      final a = hit();
      final b = hit();
      final c = hit();

      expect(
        _describe(
          Filter.andGroup([
            Filter.orGroup([a, b]),
            c,
          ]),
        ),
        [
          'and',
          ['or', a, b],
          c,
        ],
      );
      expect(
        _describe(
          Filter.orGroup([
            Filter.andGroup([a, b]),
            c,
          ]),
        ),
        [
          'or',
          ['and', a, b],
          c,
        ],
      );
    });

    test('flattens at every depth', () {
      final a = hit();
      final b = hit();
      final c = hit();
      final d = hit();

      final nested = FilterGroup([
        FilterGroup([
          FilterGroup([a, b], true),
          c,
        ], true),
        d,
      ], true);

      expect(_describe(nested.reduce()), ['and', a, b, c, d]);
    });

    test('is idempotent', () {
      for (final filter in cases()) {
        final once = filter.reduce();
        expect(
          _describe(once.reduce()),
          _describe(once),
          reason: _describe(filter).toString(),
        );
      }
    });

    test('leaves no empty, nothing or redundant groups behind', () {
      void check(Filter filter, Filter original) {
        if (filter case FilterGroup(:final filters, :final isConjunction)) {
          final reason = _describe(original).toString();
          expect(filters.length, greaterThanOrEqualTo(2), reason: reason);
          for (final operand in filters) {
            expect(operand, isNot(isA<EmptyFilter>()), reason: reason);
            expect(operand, isNot(isA<NothingFilter>()), reason: reason);
            if (operand case FilterGroup(isConjunction: final inner)) {
              expect(inner, isNot(isConjunction), reason: reason);
            }
            check(operand, original);
          }
        }
      }

      for (final filter in cases()) {
        check(filter.reduce(), filter);
      }
    });

    test('preserves the set of matched objects', () {
      for (final filter in cases()) {
        for (final person in [alice, bob, charlie]) {
          expect(
            filter.reduce().matches(person),
            filter.matches(person),
            reason: '${person.name}: ${_describe(filter)}',
          );
        }
      }
    });

    // The shape built by `TaskManager._updateTimeoutTasks`.
    test('reduces the task manager timeout filter', () {
      final state = hit();
      final noHeartbeat = hit();
      final startedBefore = hit();
      final heartbeatBefore = hit();

      final filter = Filter.andGroup([
        state,
        Filter.orGroup([
          Filter.andGroup([noHeartbeat, startedBefore]),
          heartbeatBefore,
        ]),
      ]);

      expect(_describe(filter), [
        'and',
        state,
        [
          'or',
          ['and', noHeartbeat, startedBefore],
          heartbeatBefore,
        ],
      ]);
    });
  });
}

const _empty = 'empty';
const _nothing = 'nothing';

/// Renders the structure of [filter] so trees can be compared without value
/// equality on the node types. Leaves compare by identity.
Object _describe(Filter filter) => switch (filter) {
  EmptyFilter() => _empty,
  NothingFilter() => _nothing,
  CompareFilter() => filter,
  FilterGroup(:final filters, :final isConjunction) => [
    isConjunction ? 'and' : 'or',
    ...filters.map(_describe),
  ],
};
