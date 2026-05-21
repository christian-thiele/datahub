import 'package:datahub/utils.dart';
import 'package:test/test.dart';

void main() {
  test('Bas64Uint Encode / Decode', () {
    final bigInt = BigInt.from(2).pow(128);

    final encoded = base64UintEncode(bigInt);
    final decoded = base64UintDecode(encoded);

    expect(bigInt, equals(decoded));
  });
}
