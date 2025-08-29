import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'collection_resource_builder.dart';
import 'element_resource_builder.dart';

abstract class ResourceBuilder {
  static const builders = [
    ElementResourceBuilder(),
    CollectionResourceBuilder(),
  ];

  const ResourceBuilder();

  Type get baseType;

  Iterable<String> buildClientAccessor(FieldElement element);
  Iterable<String> buildProviderMethodStubs(FieldElement element);
  Iterable<String> buildProviderAccessor(FieldElement element);

  static ResourceBuilder get(DartType type) {
    return builders.firstWhere(
      (b) => TypeChecker.fromRuntime(b.baseType).isAssignableFromType(type),
      orElse: () => throw Exception('Unknown resource type $type.'),
    );
  }
}
