import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:cl_datahub_common/common.dart';
import 'package:source_gen/source_gen.dart';

import 'field_type.dart';
import 'transfer_bean_builder.dart';
import 'transfer_field.dart';
import '../utils.dart';

class TransferBeanGenerator extends GeneratorForAnnotation<TransferObject> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    final classFields = podoFields(classElement);

    final transferFields = classFields
        .map((f) => TransferField(
              f.a.name,
              f.a.name,
              FieldType.fromDartType(f.a.type),
              f.a.type.nullabilitySuffix != NullabilitySuffix.none,
              null,
              f.b.isNamed,
            ))
        .toList();

    yield* TransferBeanBuilder(classElement.name, transferFields).build();
  }
}
