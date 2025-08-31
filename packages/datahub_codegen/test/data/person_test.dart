import 'dart:convert';
import 'dart:math';
import 'package:test/test.dart';

import 'person.dart';

void main() {
  test('Person encode / decode', () {
    final person = Person(
      firstName: 'Testmann',
      lastName: 'Peter',
      phone: ['+12345 67890', '0999888777'],
      email: ['test@test.com'],
      birthday: DateTime(1990, 05, 03),
      isBlocked: false,
      picture: utf8.encode('fun with bytes'),
    );

    print(jsonEncode(person));

    final other = Person.fromJson(jsonDecode(jsonEncode(person)));
    print(jsonEncode(person));

    expect(person == other, isTrue);
  });
}
