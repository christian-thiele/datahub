import 'package:datahub/datahub.dart';

import 'example_enum.dart';

part 'arrays_data.g.dart';

@Data()
class const ArraysData({
  final List<String> stringArray = const [],
  final List<int> intArray = const [],
  final List<double> doubleArray = const [],
  final List<bool> boolArray = const [],
  final List<ExampleEnum> enumArray = const [],
  final List<dynamic> jsonList = const [],
  final Map<String, dynamic> jsonMap = const {},
}) extends $ArraysData;
