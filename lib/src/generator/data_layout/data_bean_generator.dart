import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cl_datahub/persistence.dart';
import 'package:source_gen/source_gen.dart';

import 'data_bean_builder.dart';
import '../utils.dart';

class DataBeanGenerator extends GeneratorForAnnotation<DaoType> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertPodo(element);
    final classFields = podoFields(classElement);
    final layoutName = getLayoutName(classElement);
    yield* DataBeanBuilder(classElement.name, layoutName, classFields).build();
  }
}
