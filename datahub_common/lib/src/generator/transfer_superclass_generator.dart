import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cl_datahub_common/common.dart';
import 'package:source_gen/source_gen.dart';

import 'transfer_superclass_builder.dart';
import 'utils.dart';

class TransferSuperclassGenerator
    extends GeneratorForAnnotation<TransferObject> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    yield* TransferSuperclassBuilder(classElement.name).build();
  }
}
