import 'package:analyzer/dart/element/type.dart';

class DataBeanException implements Exception {
  final String message;

  DataBeanException(this.message);

  DataBeanException.invalidType(DartType t)
      : this('Invalid field type: ${t.element?.name}');

  @override
  String toString() => message;
}
