import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:datahub/datahub.dart';
import 'package:source_gen/source_gen.dart';

import 'package:datahub_codegen/utils.dart';

import 'data_bean_builder.dart';

class DataBeanGenerator extends GeneratorForAnnotation<DaoType> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final classElement = assertPodo(element);
    final classFields = podoFields(classElement);
    final namingConvention = getNamingConvention(classElement);
    final layoutName = getLayoutName(classElement, namingConvention);
    return DataBeanBuilder(
            classElement.name, layoutName, classFields, namingConvention)
        .build()
        .join('\n\n');
  }
}
