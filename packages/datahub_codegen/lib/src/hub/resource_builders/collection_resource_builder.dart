import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:datahub/hub.dart';
import 'package:datahub_codegen/utils.dart';

import 'resource_builder.dart';

class CollectionResourceBuilder extends ResourceBuilder {
  @override
  final baseType = CollectionResource;

  const CollectionResourceBuilder();

  @override
  Iterable<String> buildClientAccessor(FieldElement element) sync* {
    final annotation = getAnnotation(element.getter!, HubResource) ??
        (throw Exception(
            'Resource "${element.name}" does not provide HubResource annotation.'));

    final returnType = element.getter!.returnType as ParameterizedType;
    final transferClass = returnType.typeArguments.first;
    final idClass = returnType.typeArguments[1];

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.name}" getter must be nun-nullable.');
    }

    final bean = '${transferClass}TransferBean';

    final implementation = 'CollectionResourceRestClient'
        '(_client, RoutePattern(\'\$basePath${readFieldLiteral(annotation, 'path')}\'), $bean,)';

    final returnTypeName = 'CollectionResourceClient<$transferClass, $idClass>';
    yield '@override late final $returnTypeName ${element.name} = $implementation;';
  }

  @override
  Iterable<String> buildProviderMethodStubs(FieldElement element) sync* {
    final returnType = element.getter!.returnType as ParameterizedType;

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.getDisplayString(withNullability: false)}" does not provide HubResource annotation.');
    }

    final transferClass = returnType.typeArguments.first;
    final capitalizedName = element.name.firstUpper;
    final idClass = returnType.typeArguments[1];

    yield 'Stream<CollectionWindowEvent<$transferClass, $idClass>> get${capitalizedName}Window(ApiRequest request, int offset, int length);';
  }

  @override
  Iterable<String> buildProviderAccessor(FieldElement element) sync* {
    final annotation = getAnnotation(element.getter!, HubResource) ??
        (throw Exception(
            'Resource "${element.getDisplayString(withNullability: false)}" does not provide HubResource annotation.'));

    final returnType = element.getter!.returnType as ParameterizedType;

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.getDisplayString(withNullability: false)}" does not provide HubResource annotation.');
    }

    final transferClass = returnType.typeArguments.first;
    final bean = '${transferClass}TransferBean';
    final idClass = returnType.typeArguments[1];

    final capitalizedName = element.name.firstUpper;
    final methods = [
      'get${capitalizedName}Window',
    ].join(', ');

    final implementation = '${'CollectionResourceAdapter'}'
        '(RoutePattern(\'${readFieldLiteral(annotation, 'path')}\'), $bean, $methods,)';

    final returnTypeName =
        'CollectionResourceProvider<$transferClass, $idClass>';

    yield '@override late final $returnTypeName ${element.name} = $implementation;';
  }
}
