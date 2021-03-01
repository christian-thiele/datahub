import 'package:cl_datahub/utils.dart';
import 'package:test/test.dart';

void main() {
  test('Random Token', _testToken);
}

//TODO more useful tests (uniqueness etc.)
void _testToken() {
  final tokens = List.generate(1024, (index) => Token());
  tokens.forEach((element) {print(element);});
  expect(tokens.map((e) => e.bytes), everyElement(hasLength(16)));
  expect(tokens.map((e) => e.toString()), everyElement(hasLength(32)));
}
