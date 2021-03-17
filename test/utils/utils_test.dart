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
    test('mirror', _testMirror);
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

@DaoType(name: 'test')
class TestClass {
  int x;
  final String y;

  @PrimaryKeyDaoField()
  final String z;

  @ForeignKeyDaoField(OtherTestClass)
  final String foreign;

  TestClass(this.x, this.y, this.z, this.foreign);
}

class OtherTestClass {
  @PrimaryKeyDaoField()
  final String prim;

  final String name;
  final String key;
  final bool whatever;
  final DateTime when;

  OtherTestClass(this.prim, this.name, this.key, this.whatever, this.when);
}

void _testMirror() {
  final testLayout = LayoutMirror.reflect(TestClass);
  final otherTestLayout = LayoutMirror.reflect(OtherTestClass);

  print(testLayout.name);
  print(testLayout.fields.map((e) => '${e.type} - ${e.name} (${e.length})').join('\n'));

  print(otherTestLayout.name);
  print(otherTestLayout.fields.map((e) => '${e.type} - ${e.name} (${e.length})').join('\n'));

}
