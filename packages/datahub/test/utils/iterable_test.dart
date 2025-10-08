import 'package:datahub/datahub.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('SeparatedBy', () {
    expect(['a'].separatedBy('x'), equals(['a']));
    expect(['a', 'b'].separatedBy('x'), equals(['a', 'x', 'b']));
    expect(['a', 'b', 'c'].separatedBy('x'), equals(['a', 'x', 'b', 'x', 'c']));
    expect([].separatedBy('x'), equals([]));
  });
}
