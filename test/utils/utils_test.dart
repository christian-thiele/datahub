import 'dart:convert';

import 'package:datahub/src/cli/utils.dart';
import 'package:datahub/utils.dart';
import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('object equality', _testTokenEquality);
    test('unique generator', _testToken);
  });
  group('CLI Utils', () {
    test('LineTransformer', _lineTransformerTest);
  });
}

void _testTokenEquality() {
  final tokenA = Token();
  final tokenB = Token();
  final tokenC = Token.withBytes(tokenA.bytes);

  expect(tokenA, equals(tokenA));
  expect(tokenB, equals(tokenB));
  expect(tokenC, equals(tokenC));

  expect(tokenA, isNot(equals(tokenB)));
  expect(tokenA, equals(tokenC));
  expect(tokenB, isNot(equals(tokenC)));
}

void _testToken() {
  final tokens = List.generate(1024, (index) => Token());
  expect(tokens.map((e) => e.bytes), everyElement(hasLength(16)));
  expect(tokens.map((e) => e.toString()), everyElement(hasLength(32)));
  expect(tokens.distinct(), hasLength(tokens.length));
}

Future<void> _lineTransformerTest() async {
  final stream = Stream.fromIterable([
    'some',
    ' stuff\nand \nmore lines',
    '\ni ',
    'guess'
  ].map(utf8.encode))
      .transform(LineTransformer());

  expect(stream, emitsInOrder(['some stuff', 'and ', 'more lines', 'i guess']));

  final stream2 = Stream.fromIterable([
    'some',
    ' stuff\nand \nmore lines',
    '\ni ',
    'guess\n'
  ].map(utf8.encode))
      .transform(LineTransformer());

  expect(stream2,
      emitsInOrder(['some stuff', 'and ', 'more lines', 'i guess', '']));
}
