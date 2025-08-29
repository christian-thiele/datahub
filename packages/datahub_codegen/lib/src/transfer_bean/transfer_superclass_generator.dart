import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:datahub/datahub.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'package:datahub_codegen/utils.dart';

import 'transfer_superclass_builder.dart';

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
        (idField != null) ? TransferFieldType.fromDartType(idField.type) : null;
    yield* TransferSuperclassBuilder(
      classElement.name,
      idFieldName: idField?.name,
      idFieldType: idFieldType,
    ).build();
  }
}
