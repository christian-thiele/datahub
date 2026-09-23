import 'package:datahub/data.dart';
import 'package:test/test.dart';

void main() {
  final instant = DateTime.utc(2024, 1, 1);

  _Item nested(DateTime date) => _Item(
    list: [
      _Item(list: [date], date: date, name: 'inner'),
      [
        1,
        {
          'k': [date],
        },
      ],
      {
        's': {1, 2},
      },
    ],
    map: {
      'o': _Item(
        map: {
          'k': [1],
        },
        name: 'value',
      ),
    },
    date: date,
  );

  group('DataObject equality', () {
    test('compares nested values deeply', () {
      _expectEqual(nested(instant), nested(instant));
      _expectNotEqual(
        nested(instant),
        nested(instant.add(const Duration(days: 1))),
      );
    });

    test('compares DateTimes by instant', () {
      _expectEqual(nested(instant), nested(instant.toLocal()));
      _expectEqual(_Item(date: instant), _Item(date: instant.toLocal()));
    });

    test('ignores map key order', () {
      _expectEqual(_Item(map: {'a': 1, 'b': 2}), _Item(map: {'b': 2, 'a': 1}));
    });

    test('respects list order', () {
      _expectNotEqual(
        _Item(
          list: [
            [1, 2],
          ],
        ),
        _Item(
          list: [
            [2, 1],
          ],
        ),
      );
    });

    test('distinguishes null from a value', () {
      _expectEqual(_Item(), _Item());
      _expectNotEqual(_Item(list: [1]), _Item());
      _expectNotEqual(_Item(list: [instant]), _Item(list: ['2024-01-01']));
    });

    test('is false for other types', () {
      _expectNotEqual(_Item(), Object());
      _expectNotEqual(_Item(name: 'x'), 'x');
      _expectNotEqual(_Item(), _Other());
    });

    test('deduplicates equal objects in a set', () {
      expect({nested(instant), nested(instant.toLocal())}, hasLength(1));
    });
  });
}

void _expectEqual(Object a, Object b) {
  expect(a == b, isTrue);
  expect(b == a, isTrue);
  expect(a.hashCode, b.hashCode);
}

void _expectNotEqual(Object a, Object b) {
  expect(a == b, isFalse);
  expect(b == a, isFalse);
}

DataField<_Item, F> _field<F>(String name, F Function(_Item) valueOf) =>
    DataField<_Item, F>(
      name: name,
      valueOf: valueOf,
      toJson: (value) => value,
      fromJson: (value, {String? name}) => value as F,
    );

class _Item with DataObject<_Item> {
  static final _fields = <DataField<_Item, dynamic>>[
    _field<List<Object?>?>('list', (o) => o.list),
    _field<Map<String, Object?>?>('map', (o) => o.map),
    _field<DateTime?>('date', (o) => o.date),
    _field<String>('name', (o) => o.name),
  ];

  final List<Object?>? list;
  final Map<String, Object?>? map;
  final DateTime? date;
  final String name;

  _Item({this.list, this.map, this.date, this.name = ''});

  @override
  String get $$name => 'Item';

  @override
  List<DataField<_Item, dynamic>> get $$fields => _fields;

  @override
  Map<String, dynamic> toJson() => {};
}

class _Other with DataObject<_Other> {
  @override
  String get $$name => 'Other';

  @override
  List<DataField<_Other, dynamic>> get $$fields => const [];

  @override
  Map<String, dynamic> toJson() => {};
}
