import 'package:datahub/utils.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const _passwords = [
  'secretpassword',
  'abc123',
  '()"§)Q?I=Q?OLVAÖSÄ:_CY',
  '',
  '(QCNUsam890i3 uw3irshawf89whw9 /""§()Jnaeklafso f8aj f390j902fß i2qd0ßdia ',
];

void main() {
  test('Argon2Id Encrypt / Verify', () async {
    for (final password in _passwords) {
      await _encryptAndValidate(password);
    }
  });
}

Future<void> _encryptAndValidate(String password) async {
  final hash = await Argon2Id.createEncodedHash(password);
  expect(hash, startsWith('\$argon2id'));
  expect(Argon2Id.verify(password, hash), completion(isTrue));
  for (final wrongPassword in _passwords.where((p) => p != password)) {
    expect(Argon2Id.verify(wrongPassword, hash), completion(isFalse));
  }
}
