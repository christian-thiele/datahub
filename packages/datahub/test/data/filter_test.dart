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
}
