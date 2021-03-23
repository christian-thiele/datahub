void main() {

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