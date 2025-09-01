import 'package:datahub/data.dart';

part 'person.g.dart';

@Data()
class Person extends _Person {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime? birthday;

  const Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthday,
  });

  static DataBean<Person> get bean => _Person.bean;
}
