import 'package:datahub/data.dart';

part 'person.g.dart';

@Data()
class Person extends _Person {
  @Id()
  final int id;
  final String firstName;
  final String lastName;
  final DateTime? birthday;
  final bool isSpecial;

  const Person({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.isSpecial,
  });

  static DataBean<Person> get bean => _Person.bean;
}
