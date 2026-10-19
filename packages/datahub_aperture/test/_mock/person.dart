import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'person.g.dart';

@Data()
@Meta(icon: Icons.person)
@ApertureRelation<Person>()
@ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}')
class const Person({
  @Id(auto: true) final int id = 0,
  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 3)
  @MaxLengthConstraint(length: 30)
  required final String firstName,
  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 3)
  required final String lastName,
  @ApertureField(isDisplayField: true)
  @ElementConstraint(constraint: RegExpConstraint(expression: '^[^\\s]*\$'))
  required final List<String> nicknames,
  @RegExpConstraint(expression: '[\\w-.]+ \\d+\\w*')
  required final String address,
  required final Geometry homeLocation,
  @RelationId<Person>() final int? parentId,
}) extends $Person;
