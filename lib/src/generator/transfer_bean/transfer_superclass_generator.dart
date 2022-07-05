import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:cl_datahub_common/common.dart';
import 'field_type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'transfer_superclass_builder.dart';
import '../utils.dart';

class TransferSuperclassGenerator
    extends GeneratorForAnnotation<TransferObject> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    final idField = findTransferIdField(classElement);

    if (idField != null &&
        idField.type.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Only non-nullable String and int are allowed as ID-field types.');
    }

    final idFieldType =
        (idField != null) ? FieldType.fromDartType(idField.type) : null;
    yield* TransferSuperclassBuilder(
      classElement.name,
      idFieldName: idField?.name,
      idFieldType: idFieldType,
    ).build();
  }
}
