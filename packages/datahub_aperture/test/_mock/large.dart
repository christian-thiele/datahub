import 'package:datahub/data.dart';

import 'enum_example.dart';

part 'large.g.dart';

@Data()
class Large extends $Large {
  const Large({
    this.id = 0,
    required this.intProperty,
    required this.intListProperty,
    required this.doubleProperty,
    required this.doubleListProperty,
    required this.stringProperty,
    required this.stringListProperty,
    required this.boolProperty,
    required this.boolListProperty,
    required this.enumProperty,
    required this.enumListProperty,
    required this.jsonProperty,
    required this.jsonListProperty,
  });

  @Id()
  final int id;

  final int intProperty;
  final List<int> intListProperty;

  final double doubleProperty;
  final List<double> doubleListProperty;

  final String stringProperty;
  final List<String> stringListProperty;

  final bool boolProperty;
  final List<bool> boolListProperty;

  final EnumExample enumProperty;
  final List<EnumExample> enumListProperty;

  final Map<String, dynamic> jsonProperty;
  final List<dynamic> jsonListProperty;
}