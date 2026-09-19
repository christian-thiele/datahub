import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

part 'person.g.dart';

@Data()
@Meta(icon: Icons.person)
@ApertureRelation<Person>()
@ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}')
class Person extends $Person {
  @Id(auto: true)
  final int id;
  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 3)
  @MaxLengthConstraint(length: 30)
  final String firstName;
  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 3)
  final String lastName;
  @ApertureField(isDisplayField: true)
  @ElementConstraint(constraint: RegExpConstraint(expression: '^[^\\s]*\$'))
  final List<String> nicknames;
  @RegExpConstraint(expression: '[\\w-.]+ \\d+\\w*')
  final String address;
  final Geometry homeLocation;

  @RelationId<Person>()
  final int? parentId;

  const Person({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    required this.nicknames,
    required this.address,
    required this.homeLocation,
    this.parentId,
  });
}
