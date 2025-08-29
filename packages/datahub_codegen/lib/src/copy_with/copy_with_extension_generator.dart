import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:datahub/datahub.dart';
import 'package:source_gen/source_gen.dart';

import 'package:datahub_codegen/utils.dart';

import 'copy_with_extension_builder.dart';

class CopyWithExtensionGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    final classFields = podoFields(classElement);
    yield* CopyWithExtensionBuilder(classElement.name, classFields).build();
  }
}
