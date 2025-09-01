import 'dart:typed_data';

import 'package:datahub/data.dart';

part 'person.g.dart';

@Data()
class Person extends _Person {
  final int id;
  final String firstName;
  final String lastName;
  final List<String> phone;
  final List<String> email;
  final DateTime? birthday;
  final bool isBlocked;
  final Uint8List picture;

  const Person({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.birthday,
    required this.isBlocked,
    required this.picture,
  });

  static DataBean<Person> get bean => _Person.bean;
}
