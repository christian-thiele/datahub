import 'package:datahub/data.dart';

part 'city.g.dart';

@Data()
class City extends $City {
  @Id()
  final String id;
  final String name;
  final String zip;

  const City({required this.id, required this.name, required this.zip});
}
