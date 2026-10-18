import 'dart:convert';

import 'package:datahub/data.dart';
import 'package:test/test.dart';

import 'contact.dart';
import 'contact_type.dart';

void main() {
  group('Primary constructors', () {
    test('named declaring parameters encode / decode', () {
      final contact = Contact(
        name: 'Peter Testmann',
        email: 'peter@test.com',
        type: ContactType.work,
        tags: const ['friend'],
        note: 'some note',
      );

      final jsonMap = contact.toJson();
      expect(
        jsonMap,
        equals({
          'id': 0,
          'display_name': 'Peter Testmann',
          'email': 'peter@test.com',
          'type': 'work-contact',
          'tags': ['friend'],
          'note': 'some note',
        }),
      );

      final other = $Contact.bean.fromJson(jsonDecode(jsonEncode(jsonMap)));
      expect(other == contact, isTrue);
      expect(other.note, equals('some note'));
    });

    test('defaults, meta and constraints of declaring parameters', () {
      final contact = $Contact.fromJson({
        'display_name': 'Peter',
        'email': 'pe',
        'note': '',
      });

      expect(contact.id, equals(0));
      expect(contact.tags, isEmpty);
      expect(contact.type, isNull);

      expect($Contact.$id.meta, contains(isA<Id>()));
      expect($Contact.$email.constraints, contains(isA<MinLengthConstraint>()));
      expect($Contact.$type.constraints, contains(isA<EnumConstraint>()));
      expect(
        $Contact.bean.checkConstraints(contact).keys,
        contains($Contact.$email),
      );
    });

    test('copyWith with private named parameter', () {
      final contact = Contact(
        name: 'Peter',
        email: 'peter@test.com',
        type: ContactType.personal,
        note: 'a',
      );

      final copy = contact.copyWith(note: 'b', nullType: true);
      expect(copy.note, equals('b'));
      expect(copy.type, isNull);
      expect(copy.name, equals('Peter'));
    });

    test('positional declaring parameters', () {
      const vector = Vector(1, 2);
      expect(vector.toJson(), equals({'x': 1, 'y': 2}));
      expect($Vector.bean.fields, hasLength(3));

      final other = $Vector.fromJson({'x': 1, 'y': 2, 'z': 3});
      expect(other.x, equals(1));
      expect(other.y, equals(2));
      expect(other.z, equals(3));

      expect(other.copyWith(nullZ: true) == vector, isTrue);
      expect($Vector.fromValues({'x': 1, 'y': 2}) == vector, isTrue);
    });

    test('named primary constructor', () {
      const address = Address.create(streetName: 'Main Street', houseNumber: 5);
      final jsonMap = address.toJson();
      expect(
        jsonMap,
        equals({'street_name': 'Main Street', 'house_number': 5}),
      );
      expect($Address.fromJson(jsonMap) == address, isTrue);
      expect(address.copyWith(houseNumber: 7).houseNumber, equals(7));
    });
  });
}
