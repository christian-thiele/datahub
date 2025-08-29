import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:datahub/datahub.dart';
import 'package:source_gen/source_gen.dart';

import 'package:datahub_codegen/utils.dart';

import 'hub_provider_builder.dart';

class HubProviderGenerator extends GeneratorForAnnotation<Hub> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertClass(element);

    if (classElement.unnamedConstructor == null) {
      throw Exception(
          'Annotated class must provide an unnamed default constructor.');
    }

    if (classElement.hasNonFinalField) {
      throw Exception('Annotated class must not have non-final fields.');
    }

    final constructor = classElement.unnamedConstructor!;

    if (constructor.parameters.isNotEmpty) {
      throw Exception('Unnamed constructor must not have any parameters.');
    }

    final hubResourceFields = classElement.fields
        .where((e) =>
            e.getter?.isAbstract == true &&
            e.setter == null &&
            e.getter!.returnType.isResource)
        .toList();

    yield* HubProviderBuilder(classElement.name, hubResourceFields).build();
  }
}
