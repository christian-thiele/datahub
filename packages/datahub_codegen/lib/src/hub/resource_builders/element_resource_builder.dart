import 'resource_builder.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:datahub/hub.dart';
import 'package:datahub_codegen/utils.dart';
import 'package:source_gen/source_gen.dart';

class ElementResourceBuilder extends ResourceBuilder {
  @override
  final baseType = ElementResource;

  const ElementResourceBuilder();

  @override
  Iterable<String> buildClientAccessor(FieldElement element) sync* {
    final isMutable = TypeChecker.fromRuntime(MutableElementResource)
        .isAssignableFromType(element.type);

    final annotation = getAnnotation(element.getter!, HubResource) ??
        (throw Exception(
            'Resource "${element.name}" does not provide HubResource annotation.'));

    final returnType = element.getter!.returnType as ParameterizedType;
    final transferClass = returnType.typeArguments.first;

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.name}" getter must be nun-nullable.');
    }

    final bean = '${transferClass}TransferBean';

    final implementation =
        '${isMutable ? 'MutableElementResourceRestClient' : 'ElementResourceRestClient'}'
        '(_client, RoutePattern(\'\$basePath${readFieldLiteral(annotation, 'path')}\'), $bean,)';

    final returnTypeName = isMutable
        ? 'MutableElementResourceClient<$transferClass>'
        : 'ElementResourceClient<$transferClass>';

    yield '@override late final $returnTypeName ${element.name} = $implementation;';
  }

  @override
  Iterable<String> buildProviderMethodStubs(FieldElement element) sync* {
    final isMutable = TypeChecker.fromRuntime(MutableElementResource)
        .isAssignableFromType(element.type);

    final returnType = element.getter!.returnType as ParameterizedType;

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.getDisplayString(withNullability: false)}" does not provide HubResource annotation.');
    }

    final transferClass = returnType.typeArguments.first;
    final capitalizedName = element.name.firstUpper;

    yield 'Future<$transferClass> get$capitalizedName(ApiRequest request);';

    if (isMutable) {
      yield 'Future<void> set$capitalizedName(ApiRequest request, $transferClass value);';
    }

    yield 'Stream<$transferClass> get${capitalizedName}Stream(ApiRequest request);';
  }

  @override
  Iterable<String> buildProviderAccessor(FieldElement element) sync* {
    final isMutable = TypeChecker.fromRuntime(MutableElementResource)
        .isAssignableFromType(element.type);
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

    final capitalizedName = element.name.firstUpper;
    final methods = [
      'get$capitalizedName',
      if (isMutable) 'set$capitalizedName',
      'get${capitalizedName}Stream',
    ].join(', ');

    final implementation =
        '${isMutable ? 'MutableElementResourceAdapter' : 'ElementResourceAdapter'}'
        '(RoutePattern(\'${readFieldLiteral(annotation, 'path')}\'), $bean, $methods,)';

    final returnTypeName = isMutable
        ? 'MutableElementResourceProvider<$transferClass>'
        : 'ElementResourceProvider<$transferClass>';

    yield '@override late final $returnTypeName ${element.name} = $implementation;';
  }
}
