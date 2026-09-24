import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';
import 'package:test/test.dart';

final _bean = DataBean<DataObject>(
  name: 'Example',
  fields: const [],
  fromValues: (_) => throw UnimplementedError(),
  fromJson: (_, {name}) => throw UnimplementedError(),
);

ResourceField _describe<T>(
  String name, {
  List<DataFieldConstraint> constraints = const [],
}) => fieldDescription(
  _bean,
  DataField<DataObject, T>(
    name: name,
    valueOf: (_) => throw UnimplementedError(),
    toJson: (value) => value,
    fromJson: (value, {name}) => value as T,
    constraints: constraints,
  ),
  const [],
);

enum ExampleEnum { one, two }

void main() {
  group('fieldDescription', () {
    test('describes Map<String, dynamic> as jsonMap', () {
      final field = _describe<Map<String, dynamic>>('settings');

      expect(field.type, ResourceFieldType.jsonMap);
      expect(field.nullable, isFalse);
      expect(field.objectDescription, isEmpty);
    });

    test('describes Map<String, dynamic>? as nullable jsonMap', () {
      final field = _describe<Map<String, dynamic>?>('settings');

      expect(field.type, ResourceFieldType.jsonMap);
      expect(field.nullable, isTrue);
    });

    test('describes List<dynamic> as jsonList without element', () {
      final field = _describe<List<dynamic>>('entries');

      expect(field.type, ResourceFieldType.jsonList);
      expect(field.nullable, isFalse);
      expect(field.objectDescription, isEmpty);
    });

    test('describes List<dynamic>? as nullable jsonList', () {
      final field = _describe<List<dynamic>?>('entries');

      expect(field.type, ResourceFieldType.jsonList);
      expect(field.nullable, isTrue);
    });

    test('still describes typed lists as list with element', () {
      final field = _describe<List<String>>('tags');

      expect(field.type, ResourceFieldType.list);
      expect(field.objectDescription, [
        isA<ResourceField>()
            .having((e) => e.id, 'id', 'element')
            .having((e) => e.type, 'type', ResourceFieldType.string),
      ]);
    });

    test('describes nullable typed lists as nullable list with element', () {
      final field = _describe<List<String>?>('tags');

      expect(field.type, ResourceFieldType.list);
      expect(field.nullable, isTrue);
      expect(field.objectDescription, [
        isA<ResourceField>()
            .having((e) => e.id, 'id', 'element')
            .having((e) => e.type, 'type', ResourceFieldType.string),
      ]);
    });

    test('describes constraints of the field', () {
      final field = _describe<String>(
        'name',
        constraints: const [
          RegExpConstraint(expression: r'^\w+$'),
          MaxLengthConstraint(length: 20),
        ],
      );

      expect(field.validation, r'^\w+$');
      expect(field.length, 20);
    });

    test('describes element constraints of a list on its element', () {
      final field = _describe<List<String>>(
        'tags',
        constraints: const [
          ElementConstraint(constraint: RegExpConstraint(expression: r'^\w+$')),
          ElementConstraint(constraint: MaxLengthConstraint(length: 8)),
        ],
      );

      // the constraints apply to the elements, not to the list itself
      expect(field.validation, isNull);
      expect(field.length, isNull);
      expect(field.objectDescription, [
        isA<ResourceField>()
            .having((e) => e.id, 'id', 'element')
            .having((e) => e.validation, 'validation', r'^\w+$')
            .having((e) => e.length, 'length', 8),
      ]);
    });

    test('describes enum element constraints of a list on its element', () {
      final field = _describe<List<ExampleEnum>>(
        'states',
        constraints: const [
          ElementConstraint(
            constraint: EnumConstraint(values: ExampleEnum.values),
          ),
        ],
      );

      expect(field.enumValues, isNull);
      expect(field.objectDescription, [
        isA<ResourceField>()
            .having((e) => e.type, 'type', ResourceFieldType.stringEnum)
            .having((e) => e.enumValues, 'enumValues', ['one', 'two']),
      ]);
    });

    test('does not treat typed maps as JSON', () {
      expect(
        () => _describe<Map<String, String>>('labels'),
        throwsA(isA<ApiError>()),
      );
    });
  });
}
