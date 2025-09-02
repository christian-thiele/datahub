import 'package:boost/boost.dart';

class Person {
  final String name;
  final bool clubMember;

  Person(this.name, this.clubMember);
}

void main() {
  final people = [
    Person('Joe', false),
    Person('Alex', true),
    Person('Grace', true),
    Person('Tina', false),
    Person('Max', false),
  ];

  final split = people.split((p) => p.clubMember);
  print('${split.$1.length} people are club Members:');
  split.$1.forEach((p) => print(p.name));

  print('${split.$2.length} people are not:');
  split.$2.forEach((p) => print(p.name));
}
