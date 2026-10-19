import 'package:datahub/data.dart';

part 'person.g.dart';

@Data()
class const Person({
  @Id(auto: true) final int id = 0,
  required final String firstName,
  required final String lastName,
  required final DateTime? birthday,
  final bool isSpecial = false,
}) extends $Person;
