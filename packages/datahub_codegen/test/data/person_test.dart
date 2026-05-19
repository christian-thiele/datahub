import 'dart:convert';
import 'package:datahub/data.dart';
import 'package:test/test.dart';

import 'contact_type.dart';
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
      type: ContactType.personal,
    );

    final jsonMap = person.toJson();
    final jsonString = jsonEncode(jsonMap);

    expect(
      jsonMap,
      equals({
        'id': 0,
        'firstName': 'Testmann',
        'lastName': 'Peter',
        'phone': ['+12345 67890', '0999888777'],
        'email': ['test@test.com'],
        'birthday': JsonDataCodec().encodeDateTime(DateTime(1990, 05, 03)),
        'isBlocked': false,
        'picture': base64.encode(utf8.encode('fun with bytes')),
        'type': 'personal-contact',
      }),
    );

    final other = $Person.bean.fromJson(jsonDecode(jsonString));
    expect(person == other, isTrue);
  });
}
