import 'package:datahub/datahub.dart';

part 'pet.g.dart';

enum PetKind { cat, dog, other }

@Data()
@Meta(name: 'Pet', description: 'A pet in the store.')
class Pet extends $Pet {
  @Id(auto: true)
  final int id;

  @MinLengthConstraint(length: 3)
  @MaxLengthConstraint(length: 30)
  final String name;

  final PetKind kind;

  @Meta(description: 'Age in years.')
  @RangeConstraint(min: 0, max: 100)
  final int? age;

  final bool vaccinated;

  final DateTime? born;

  @ElementConstraint(constraint: RegExpConstraint(expression: r'^[a-z]+$'))
  final List<String> tags;

  final Owner? owner;

  const Pet({
    this.id = 0,
    required this.name,
    required this.kind,
    this.age,
    required this.vaccinated,
    this.born,
    this.tags = const [],
    this.owner,
  });
}

@Data()
class Owner extends $Owner {
  final String name;
  final List<Pet> pets;

  const Owner({required this.name, this.pets = const []});
}
