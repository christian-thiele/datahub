import 'package:datahub/datahub.dart';

import 'example_enum.dart';

part 'arrays_data.g.dart';

@Data()
class ArraysData extends $ArraysData {
  final List<String> stringArray;
  final List<int> intArray;
  final List<double> doubleArray;
  final List<bool> boolArray;
  final List<ExampleEnum> enumArray;
  final List<dynamic> jsonList;
  final Map<String, dynamic> jsonMap;

  const ArraysData({
    this.stringArray = const [],
    this.intArray = const [],
    this.doubleArray = const [],
    this.boolArray = const [],
    this.enumArray = const [],
    this.jsonList = const [],
    this.jsonMap = const {},
  });
}
