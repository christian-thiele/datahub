import 'package:datahub/datahub.dart';

part 'json_fields.g.dart';

@TransferObject()
class JsonFields extends _TransferObject {
  final List dynamicList;
  final List? dynamicListNullable;

  final List<String> typedList;
  final List<String>? typedListNullable;

  final Map<String, dynamic> dynamicMap;
  final Map<String, dynamic>? dynamicMapNullable;

  final Map<String, String> typedMap;
  final Map<String, String>? typedMapNullable;

  JsonFields({
    required this.dynamicList,
    required this.dynamicListNullable,
    required this.typedList,
    required this.typedListNullable,
    required this.dynamicMap,
    required this.dynamicMapNullable,
    required this.typedMap,
    required this.typedMapNullable,
  });
}
