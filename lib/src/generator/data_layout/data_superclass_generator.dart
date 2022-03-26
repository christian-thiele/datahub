import 'package:build/build.dart';
import 'package:cl_datahub/persistence.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'data_superclass_builder.dart';
import '../utils.dart';

class DataSuperclassGenerator extends GeneratorForAnnotation<DaoType> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    final classFields = podoFields(classElement);
    yield* DataSuperclassBuilder(classElement.name, classFields).build();
  }
}
