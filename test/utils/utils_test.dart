import 'package:cl_datahub/src/persistence/dao/mirror/dao_field.dart';
import 'package:cl_datahub/src/persistence/dao/mirror/dao_type.dart';
import 'package:cl_datahub/src/persistence/dao/mirror/layout_mirror.dart';
import 'package:cl_datahub/utils.dart';
import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('object equality', _testTokenEquality);
    test('unique generator', _testToken);
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
