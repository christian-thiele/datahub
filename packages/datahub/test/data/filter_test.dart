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

      return [
        e,
        t,
        f,
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

/// Renders the structure of [filter] so trees can be compared without value
/// equality on the node types. Leaves compare by identity.
Object _describe(Filter filter) => switch (filter) {
  EmptyFilter() => _empty,
  CompareFilter() => filter,
  FilterGroup(:final filters, :final isConjunction) => [
    isConjunction ? 'and' : 'or',
    ...filters.map(_describe),
  ],
};
