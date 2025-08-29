import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:datahub/datahub.dart';
import 'package:source_gen/source_gen.dart';

import 'package:datahub_codegen/utils.dart';

import 'transfer_bean_builder.dart';
import 'transfer_field.dart';

class TransferBeanGenerator extends GeneratorForAnnotation<TransferObject> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    final classFields = podoFields(classElement);

    final transferFields = classFields
        .map((f) => TransferField(f.a.name, f.a.name,
            TransferFieldType.fromDartType(f.a.type), f.b.isNamed))
        .toList();

    yield* TransferBeanBuilder(classElement.name, transferFields).build();
  }
}
