import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('findEnum', _findEnum);
  test('tryFindEnum', _tryFindEnum);
}

enum TestEnum { abc123, TesTvAlUE, abc, x123, OTHER, other, oThEr }

void _findEnum() {
  expect(findEnum('TesTvAlUE', TestEnum.values), equals(TestEnum.TesTvAlUE));
  expect(findEnum('abc123', TestEnum.values), equals(TestEnum.abc123));
  expect(findEnum('x123', TestEnum.values), equals(TestEnum.x123));
  expect(findEnum('OTHER', TestEnum.values), equals(TestEnum.OTHER));
  expect(findEnum('abc', TestEnum.values), equals(TestEnum.abc));
  expect(findEnum('other', TestEnum.values), equals(TestEnum.other));
  expect(findEnum('oThEr', TestEnum.values), equals(TestEnum.oThEr));

  expect(findEnum('testvalue', TestEnum.values, ignoreCase: true),
      equals(TestEnum.TesTvAlUE));
  expect(findEnum('ABC123', TestEnum.values, ignoreCase: true),
      equals(TestEnum.abc123));
  expect(findEnum('X123', TestEnum.values, ignoreCase: true),
      equals(TestEnum.x123));
  expect(findEnum('other', TestEnum.values, ignoreCase: true),
      equals(TestEnum.OTHER));

  expect(() => findEnum('testvalue', TestEnum.values),
      throwsA(isA<BoostException>()));
  expect(() => findEnum('ABC123', TestEnum.values),
      throwsA(isA<BoostException>()));
  expect(() => findEnum('something', TestEnum.values),
      throwsA(isA<BoostException>()));
}

void _tryFindEnum() {
  expect(tryFindEnum('TesTvAlUE', TestEnum.values), equals(TestEnum.TesTvAlUE));
  expect(tryFindEnum('abc123', TestEnum.values), equals(TestEnum.abc123));
  expect(tryFindEnum('x123', TestEnum.values), equals(TestEnum.x123));
  expect(tryFindEnum('OTHER', TestEnum.values), equals(TestEnum.OTHER));
  expect(tryFindEnum('abc', TestEnum.values), equals(TestEnum.abc));
  expect(tryFindEnum('other', TestEnum.values), equals(TestEnum.other));
  expect(tryFindEnum('oThEr', TestEnum.values), equals(TestEnum.oThEr));

  expect(tryFindEnum('testvalue', TestEnum.values, ignoreCase: true),
      equals(TestEnum.TesTvAlUE));
  expect(tryFindEnum('ABC123', TestEnum.values, ignoreCase: true),
      equals(TestEnum.abc123));
  expect(tryFindEnum('X123', TestEnum.values, ignoreCase: true),
      equals(TestEnum.x123));
  expect(tryFindEnum('other', TestEnum.values, ignoreCase: true),
      equals(TestEnum.OTHER));

  expect(tryFindEnum('testvalue', TestEnum.values), equals(null));
  expect(tryFindEnum('ABC123', TestEnum.values), equals(null));
  expect(tryFindEnum('something', TestEnum.values), equals(null));
}
