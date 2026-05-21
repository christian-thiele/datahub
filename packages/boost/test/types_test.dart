import 'package:test/test.dart';
import 'package:boost/boost.dart';

void main() {
  test('isNullable', _isNullableTest);
  test('toList', _toListTest);
  test('toIterable', _toIterableTest);
  test('toNullable', _toNullableTest);
  test('isList', _isListTest);
  test('isIterable', _isIterableTest);
  test('isListOfType', _isListOfTypeTest);
  test('isMap', _isMapTest);
  test('isMapOfType', _isMapOfTypeTest);
  test('isSubtypeOf', _isSubtypeOfTest);
  test('isSupertypeOf', _isSupertypeOfTest);
  test('equality', _equalityTest);
}

void _isNullableTest() {
  expect(TypeCheck<int>().isNullable, isFalse);
  expect(TypeCheck<Map>().isNullable, isFalse);
  expect(TypeCheck<Map<String, int>>().isNullable, isFalse);
  expect(TypeCheck<List>().isNullable, isFalse);
  expect(TypeCheck<List<int>>().isNullable, isFalse);
  expect(TypeCheck<Null>().isNullable, isTrue);
  expect(TypeCheck<dynamic>().isNullable, isTrue);
  expect(TypeCheck<void>().isNullable, isTrue);
}

void _toListTest() {
  expect(TypeCheck<int>().toList, equals(TypeCheck<List<int>>()));
  expect(TypeCheck<int?>().toList, equals(TypeCheck<List<int?>>()));
  expect(TypeCheck<List>().toList, equals(TypeCheck<List<List>>()));
  expect(TypeCheck<List<int>?>().toList, equals(TypeCheck<List<List<int>?>>()));
}

void _toIterableTest() {
  expect(TypeCheck<int>().toIterable, equals(TypeCheck<Iterable<int>>()));
  expect(TypeCheck<int?>().toIterable, equals(TypeCheck<Iterable<int?>>()));
  expect(TypeCheck<List>().toIterable, equals(TypeCheck<Iterable<List>>()));
  expect(TypeCheck<Iterable<int>?>().toIterable,
      equals(TypeCheck<Iterable<Iterable<int>?>>()));
}

void _toNullableTest() {
  expect(TypeCheck<int>().toNullable, equals(TypeCheck<int?>()));
  expect(TypeCheck<int?>().toNullable, equals(TypeCheck<int?>()));
  expect(TypeCheck<List>().toNullable, equals(TypeCheck<List?>()));
  expect(TypeCheck<List<int>?>().toNullable, equals(TypeCheck<List<int>?>()));
}

void _isListTest() {
  expect(TypeCheck<int>().isList, isFalse);
  expect(TypeCheck<Map>().isList, isFalse);
  expect(TypeCheck<Map<String, int>>().isList, isFalse);
  expect(TypeCheck<Iterable>().isList, isFalse);
  expect(TypeCheck<Iterable<int>>().isList, isFalse);
  expect(TypeCheck<List>().isList, isTrue);
  expect(TypeCheck<List<int>>().isList, isTrue);
  expect(TypeCheck<Null>().isList, isFalse);
  expect(TypeCheck<dynamic>().isList, isFalse);
  expect(TypeCheck<void>().isList, isFalse);
}

void _isIterableTest() {
  expect(TypeCheck<int>().isIterable, isFalse);
  expect(TypeCheck<Map>().isIterable, isFalse);
  expect(TypeCheck<Map<String, int>>().isIterable, isFalse);
  expect(TypeCheck<List>().isIterable, isTrue);
  expect(TypeCheck<List<int>>().isIterable, isTrue);
  expect(TypeCheck<Iterable>().isIterable, isTrue);
  expect(TypeCheck<Iterable<int>>().isIterable, isTrue);
  expect(TypeCheck<Null>().isIterable, isFalse);
  expect(TypeCheck<dynamic>().isIterable, isFalse);
  expect(TypeCheck<void>().isIterable, isFalse);
}

void _isListOfTypeTest() {
  expect(TypeCheck<List<int>>().isListOf<int>(), isTrue);
  expect(TypeCheck<List<int>>().isListOf<String>(), isFalse);
  expect(TypeCheck<List<String>>().isListOf<int>(), isFalse);
  expect(TypeCheck<List<String>>().isListOf<String>(), isTrue);
}

void _isMapTest() {
  expect(TypeCheck<int>().isMap, isFalse);
  expect(TypeCheck<Map>().isMap, isTrue);
  expect(TypeCheck<Map<String, int>>().isMap, isTrue);
  expect(TypeCheck<Map<Object, dynamic>>().isMap, isTrue);
  expect(TypeCheck<List>().isMap, isFalse);
  expect(TypeCheck<List<int>>().isMap, isFalse);
  expect(TypeCheck<Null>().isMap, isFalse);
  expect(TypeCheck<dynamic>().isMap, isFalse);
  expect(TypeCheck<void>().isMap, isFalse);
}

void _isMapOfTypeTest() {
  final jsonMap = TypeCheck<Map<String, dynamic>>();
  final intDoubleMap = TypeCheck<Map<int, double>>();

  expect(jsonMap.isMapOf<String, dynamic>(), isTrue);
  expect(jsonMap.isMapOf<dynamic, String>(), isFalse);
  expect(jsonMap.isMapOf<String, String>(), isFalse);

  expect(intDoubleMap.isMapOf<int, double>(), isTrue);
  expect(intDoubleMap.isMapOf<dynamic, dynamic>(), isTrue);
  expect(intDoubleMap.isMapOf<double, int>(), isFalse);
  expect(intDoubleMap.isMapOf<int, int>(), isFalse);

  expect(TypeCheck<dynamic>().isMapOf<int, int>(), isFalse);
  expect(TypeCheck<void>().isMapOf<int, int>(), isFalse);
  expect(TypeCheck<Null>().isMapOf<int, int>(), isFalse);
}

void _isSubtypeOfTest() {
  // true
  expect(TypeCheck<String>().isSubtypeOf<Object>(), isTrue);
  expect(TypeCheck<int>().isSubtypeOf<num>(), isTrue);
  expect(TypeCheck<String>().isSubtypeOf<dynamic>(), isTrue);
  expect(TypeCheck<List<int>>().isSubtypeOf<List<num>>(), isTrue);
  expect(TypeCheck<List<int>>().isSubtypeOf<List<dynamic>>(), isTrue);
  expect(TypeCheck<void>().isSubtypeOf<void>(), isTrue);

  //false
  expect(TypeCheck<int>().isSubtypeOf<String>(), isFalse);
  expect(TypeCheck<num>().isSubtypeOf<int>(), isFalse);
  expect(TypeCheck<void>().isSubtypeOf<String>(), isFalse);
}

void _isSupertypeOfTest() {
  // true
  expect(TypeCheck<Object>().isSupertypeOf<String>(), isTrue);
  expect(TypeCheck<num>().isSupertypeOf<int>(), isTrue);
  expect(TypeCheck<dynamic>().isSupertypeOf<String>(), isTrue);
  expect(TypeCheck<List<num>>().isSupertypeOf<List<int>>(), isTrue);
  expect(TypeCheck<List<dynamic>>().isSupertypeOf<List<int>>(), isTrue);
  expect(TypeCheck<void>().isSupertypeOf<void>(), isTrue);

  //false
  expect(TypeCheck<String>().isSupertypeOf<int>(), isFalse);
  expect(TypeCheck<int>().isSupertypeOf<num>(), isFalse);
  expect(TypeCheck<String>().isSupertypeOf<void>(), isFalse);
}

void _equalityTest() {
  expect(TypeCheck<int>(), equals(TypeCheck<int>()));
  expect(TypeCheck<int>(), isNot(TypeCheck<int?>()));
  expect(TypeCheck<int>(), isNot(TypeCheck<String>()));
  expect(TypeCheck<int>(), isNot(TypeCheck<void>()));
  expect(TypeCheck<int>(), isNot(TypeCheck<dynamic>()));

  expect(TypeCheck<int?>(), equals(TypeCheck<int?>()));
  expect(TypeCheck<int?>(), isNot(TypeCheck<int>()));
  expect(TypeCheck<int?>(), isNot(TypeCheck<void>()));
  expect(TypeCheck<int?>(), isNot(TypeCheck<dynamic>()));

  expect(TypeCheck<List>(), equals(TypeCheck<List>()));
  expect(TypeCheck<List>(), isNot(TypeCheck<List<String>>()));
  expect(TypeCheck<List<String>>(), isNot(TypeCheck<List>()));

  expect(TypeCheck<double>(), isNot(TypeCheck<String?>()));
  expect(TypeCheck<double?>(), isNot(TypeCheck<String>()));
  expect(TypeCheck<double>(), isNot(TypeCheck<String>()));
  expect(TypeCheck<double?>(), isNot(TypeCheck<String?>()));

  expect(TypeCheck<double?>(), isNot(TypeCheck<void>()));
  expect(TypeCheck<void>(), isNot(TypeCheck<String?>()));

  expect(TypeCheck<void>(), equals(TypeCheck<void>()));
  expect(TypeCheck<void>(), isNot(TypeCheck<dynamic>()));
  expect(TypeCheck<void>(), isNot(TypeCheck<Null>()));

  expect(TypeCheck<dynamic>(), equals(TypeCheck<dynamic>()));
  expect(TypeCheck<dynamic>(), isNot(TypeCheck<void>()));
  expect(TypeCheck<dynamic>(), isNot(TypeCheck<Null>()));

  expect(TypeCheck<Null>(), equals(TypeCheck<Null>()));
  expect(TypeCheck<Null>(), isNot(TypeCheck<void>()));
  expect(TypeCheck<Null>(), isNot(TypeCheck<dynamic>()));
}
