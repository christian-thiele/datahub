import 'package:analyzer/dart/element/element.dart';

import 'resource_builders/resource_builder.dart';

class HubClientBuilder {
  final String hubClass;
  final List<FieldElement> resourceFields;

  HubClientBuilder(this.hubClass, this.resourceFields);

  Iterable<String> build() sync* {
    yield 'class ${hubClass}Client extends HubClient<$hubClass> implements $hubClass {';
    yield 'final RestClient _client;';
    yield 'final String basePath;';
    yield* buildConstructor();
    yield* buildResourceClientAccessors();
    yield* buildHelperMethods();
    yield '}';
  }

  Iterable<String> buildConstructor() sync* {
    yield '${hubClass}Client(this._client, {this.basePath = \'\'});';
  }

  Iterable<String> buildResourceClientAccessors() sync* {
    for (final field in resourceFields) {
      yield* ResourceBuilder.get(field.type).buildClientAccessor(field);
    }
  }

  Iterable<String> buildHelperMethods() sync* {
    yield '@override Future<void> closeAll() async {';
    for (final field in resourceFields) {
      yield 'await ${field.name}.closeAll();';
    }
    yield '}';

    yield '@override Future<void> reconnectAll() async {';
    for (final field in resourceFields) {
      yield 'await ${field.name}.reconnectAll();';
    }
    yield '}';
  }
}
