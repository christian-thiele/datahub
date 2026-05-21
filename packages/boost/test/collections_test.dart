import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('random', _randomTest);
  test('distinct', _distinctTest);
  test('groupBy', _groupByTest);
  test('sequenceEquals', _sequenceEqualsTest);
  test('split', _splitTest);
  test('zip', _zipTest);
  test('replaceItem', _replaceItemTest);
  test('sortBy', _sortByTest);
  test('min / max', _minMaxTest);
  test('tuple', _tupleIterableTest);
  test('triple', _tripleIterableTest);
  test('separatedBy', _separatedByTest);
  test('tuple', _tupleMapTest);
  test('entriesEqual', _entriesEqualTest);
  test('equalsDeep', _equalsDeepTest);
}

void _randomTest() {
  final intList = Iterable.generate(20, (i) => 'str$i');
  final results = Iterable.generate(10, (i) => intList.random);
  final firstResult = results.first;

  expect(results, isNot(everyElement(equals(firstResult))));
}

void _distinctTest() {
  final text = 'abc def ghi def abc jkl mno ghi';
  final distinct = text.split(' ').distinct();
  expect(distinct, ['abc', 'def', 'ghi', 'jkl', 'mno']);

  final list = [
    (1, 'first 1'),
    (2, 'first 2'),
    (1, 'second 1'),
    (3, 'first 3')
  ];
  expect(list.distinct((e) => e.$1).map((e) => e.$2),
      ['first 1', 'first 2', 'first 3']);
}

void _groupByTest() {
  final people = ['Joe', 'Alex', 'Grace', 'Tina', 'Max'];
  final groups = people.groupBy((e) => e.length);
  expect(
      groups,
      equals({
        3: ['Joe', 'Max'],
        4: ['Alex', 'Tina'],
        5: ['Grace']
      }));
}

void _sequenceEqualsTest() {
  final seq1 = [1, 2, 5, 7, 9, 20];
  final seq2 = [1, 2, 5, 7, 9, 20];
  final seq3 = [1, 2, 5, 7, 20, 9];
  final seq4 = [1, 2, 5, 7];

  expect(seq1.sequenceEquals(seq1), isTrue);
  expect(seq1.sequenceEquals(seq2), isTrue);
  expect(seq1.sequenceEquals(seq3), isFalse);
  expect(seq3.sequenceEquals(seq1), isFalse);
  expect(seq3.sequenceEquals(seq2), isFalse);
  expect(seq1.sequenceEquals(seq4), isFalse);
}

void _splitTest() {
  final people = [
    ('Joe', false),
    ('Alex', true),
    ('Grace', true),
    ('Tina', false),
    ('Max', false),
  ];

  final split = people.split((p) => p.$2);
  expect(split.$1, equals(people.where((p) => p.$2)));
  expect(split.$2, equals(people.where((p) => !p.$2)));
}

void _zipTest() {
  final seq1 = ['a', 'b', 'c', 'd'];
  final seq2 = [5, 4, 3, 2, 1, 0];
  final combined = seq1.zip(seq2);

  expect(
      combined,
      equals(<(String?, int?)>[
        ('a', 5),
        ('b', 4),
        ('c', 3),
        ('d', 2),
        (null, 1),
        (null, 0),
      ]));
}

void _replaceItemTest() {
  final seq = <dynamic>['abc', 2, 0.4, false];
  seq.replaceItem(0.4, 'def');
  expect(seq, equals(['abc', 2, 'def', false]));
}

void _sortByTest() {
  final list = [
    ('g', 5),
    ('e', 2),
    ('u', 8),
    ('a', 3),
    ('f', 10),
    ('i', 4),
  ];

  list.sortBy((e) => e.$1);
  expect(list.map((e) => e.$2), [3, 2, 10, 5, 4, 8]);

  list.sortBy((e) => e.$2);
  expect(list.map((e) => e.$2), [2, 3, 4, 5, 8, 10]);
}

void _minMaxTest() {
  final intList = <int>[1, 3, 56, 2, 4, 1, 85, 5, -23, 3, 0];
  final doubleList = <double>[1.2, 3.4, 56.321, 2.0, 4.12, 5.6537, -23.34, 0.0];
  final doubleListInf = <double>[
    double.infinity,
    double.nan,
    double.negativeInfinity,
    -23.34,
    0.0
  ];
  final numList = <num>[3.4, 56.321, 2, 4.12, 12, 85.435, 5, -23.34, 3, 0.0];
  final stringList = <String>['test', 'a', 'b', 'longword!', 'abcdefg'];

  expect(intList.min(), equals(-23));
  expect(intList.max(), equals(85));
  expect(doubleList.min(), equals(-23.34));
  expect(doubleList.max(), equals(56.321));
  expect(doubleListInf.min(), equals(double.negativeInfinity));
  expect(doubleListInf.max(), equals(double.infinity));
  expect(numList.min(), equals(-23.34));
  expect(numList.max(), equals(85.435));
  expect(stringList.min((s) => s.length), equals('a'));
  expect(stringList.max((s) => s.length), equals('longword!'));

  expect(() => stringList.min(), throwsA(isA<BoostException>()));
  expect(() => stringList.max(), throwsA(isA<BoostException>()));
}

void _tupleIterableTest() {
  final list = [('1', 1), ('2', 2), ('3', 3)];
  expect(list.$1, orderedEquals(['1', '2', '3']));
  expect(list.$2, orderedEquals([1, 2, 3]));
}

void _tripleIterableTest() {
  final list = [
    ('1', 1, true),
    ('2', 2, 'abc'),
    ('3', 3, false),
  ];
  expect(list.$1, orderedEquals(['1', '2', '3']));
  expect(list.$2, orderedEquals([1, 2, 3]));
  expect(list.$3, orderedEquals([true, 'abc', false]));
}

void _separatedByTest() {
  expect(['a'].separatedBy('x'), equals(['a']));
  expect(['a', 'b'].separatedBy('x'), equals(['a', 'x', 'b']));
  expect(['a', 'b', 'c'].separatedBy('x'), equals(['a', 'x', 'b', 'x', 'c']));
  expect([].separatedBy('x'), equals([]));
}

void _tupleMapTest() {
  final map = {
    'something': 'value',
    'else': 123,
  };

  expect(map.tuples, orderedEquals([('something', 'value'), ('else', 123)]));
}

void _entriesEqualTest() {
  expect(
    {
      'key1': 1,
      'key2': '2',
      'key3': 3,
    }.entriesEqual({
      'key1': 1,
      'key2': '2',
      'key3': 3,
    }),
    isTrue,
  );

  expect(
    {
      'key1': 1,
      'key2': 2,
      'key3': 3,
    }.entriesEqual({
      'key1': 1,
      'key2': '2',
      'key3': 3,
    }),
    isFalse,
  );

  expect(
    {
      'key1': 1,
      'key2': 2,
      'key3': 3,
    }.entriesEqual({
      'key1': 1,
      'key2': 2,
      'key3': 3,
      'key4': 4,
    }),
    isFalse,
  );

  expect(
    {
      'key1': 1,
      'key2': 2,
      'key3': 3,
      'key4': 4,
    }.entriesEqual({
      'key1': 1,
      'key2': 2,
      'key3': 3,
    }),
    isFalse,
  );

  expect(
    {
      'key1': 1,
      'key2': 2,
      'key3': 3,
      'key4': 4,
    }.entriesEqual({
      'key1': 1,
      'key2': 2,
      'key3': 3,
      'key4': 5,
    }),
    isFalse,
  );
}

void _equalsDeepTest() {
  final map1 = {
    'list': [
      'a',
      'b',
      'c',
      {'key': 'value'}
    ],
    'map': {
      'key1': 1,
      'key2': 2,
    },
  };

  final map2 = {
    'list': [
      'a',
      'b',
      'c',
      {'key': 'value'}
    ],
    'map': {
      'key1': 1,
      'key2': 2,
    },
  };

  expect(map1.equalsDeep(map2), isTrue);

  final map3 = {
    'list': [
      'a',
      'b',
      'c',
      {'key': 'value'}
    ],
    'map': {
      'key1': 1,
      'key2': 2,
    },
  };

  final map4 = {
    'list': [
      'a',
      'b',
      'c',
      {'key': 'wrong-value'}
    ],
    'map': {
      'key1': 1,
      'key2': 2,
    },
  };

  expect(map3.equalsDeep(map4), isFalse);
}
