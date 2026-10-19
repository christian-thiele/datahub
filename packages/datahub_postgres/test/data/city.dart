import 'package:datahub/data.dart';

part 'city.g.dart';

@Data()
class const City({
  @Id() required final String id,
  required final String name,
  required final String zip,
}) extends $City;
