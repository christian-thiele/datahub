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

ResourceField _describe<T>(String name) => fieldDescription(
  _bean,
  DataField<DataObject, T>(
    name: name,
    valueOf: (_) => throw UnimplementedError(),
    toJson: (value) => value,
    fromJson: (value, {name}) => value as T,
  ),
  const [],
);

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

    test('does not treat typed maps as JSON', () {
      expect(
        () => _describe<Map<String, String>>('labels'),
        throwsA(isA<ApiError>()),
      );
    });
  });
}
