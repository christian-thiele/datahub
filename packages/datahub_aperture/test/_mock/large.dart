import 'package:datahub/data.dart';

import 'enum_example.dart';

part 'large.g.dart';

@Data()
class const Large({
  @Id(auto: true) final int id = 0,
  required final int intProperty,
  required final List<int> intListProperty,
  required final double doubleProperty,
  required final List<double> doubleListProperty,
  required final String stringProperty,
  required final List<String> stringListProperty,
  required final bool boolProperty,
  required final List<bool> boolListProperty,
  required final EnumExample enumProperty,
  required final List<EnumExample> enumListProperty,
  required final Map<String, dynamic> jsonProperty,
  required final List<dynamic> jsonListProperty,
}) extends $Large;
