import 'package:build/build.dart';
import 'package:cl_datahub_common/common.dart';
import 'package:source_gen/source_gen.dart';

import 'package:analyzer/dart/element/element.dart';

import 'copy_with_extension_builder.dart';
import '../utils.dart';

class CopyWithExtensionGenerator extends GeneratorForAnnotation<CopyWith> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    final classFields = podoFields(classElement);
    yield* CopyWithExtensionBuilder(classElement.name, classFields).build();
  }
}
