import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/model/json_value.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

ResourceField _field(ResourceFieldType type, {bool nullable = false}) =>
    ResourceField(id: 'field', name: 'Field', type: type, nullable: nullable);

ResourceDescription _resource(List<ResourceField> fields) =>
    ResourceDescription(
      id: 'Example',
      name: 'Example',
      icon: 0,
      fields: fields,
      relations: const [],
      idField: 'id',
      readOnly: false,
      revisable: false,
      actions: const [],
    );

/// A list field described like the backend describes it, with the type of
/// its elements in an `element` field.
ResourceField _list(
  String id,
  ResourceFieldType elementType, [
  List<ResourceField>? elementFields,
]) => ResourceField(
  id: id,
  name: id,
  type: ResourceFieldType.list,
  objectDescription: [
    ResourceField(
      id: 'element',
      name: '',
      type: elementType,
      objectDescription: elementFields,
    ),
  ],
);

const _timestamp = '2026-01-02T03:04:05.000Z';
final _dateTime = DateTime.utc(2026, 1, 2, 3, 4, 5);

void main() {
  setUpAll(() => S.load(const Locale('en')));

  group('validateFieldValue', () {
    test('accepts the kind of value a JSON field holds', () {
      expect(
        validateFieldValue(_field(ResourceFieldType.jsonMap), {'a': 1}),
        isNull,
      );
      expect(
        validateFieldValue(_field(ResourceFieldType.jsonList), []),
        isNull,
      );
    });

    test('rejects the other kind of JSON value', () {
      expect(
        validateFieldValue(_field(ResourceFieldType.jsonMap), [1]),
        'Value must be a JSON object.',
      );
      expect(
        validateFieldValue(_field(ResourceFieldType.jsonList), {'a': 1}),
        'Value must be a JSON array.',
      );
    });

    test('rejects invalid JSON with its position', () {
      expect(
        validateFieldValue(
          _field(ResourceFieldType.jsonMap),
          parseJsonText('{\n  "a": }'),
        ),
        'Invalid JSON (line 2, column 8).',
      );
    });

    test('rejects invalid JSON nested in an object field', () {
      expect(
        validateFieldValue(_field(ResourceFieldType.object), {
          'settings': parseJsonText('['),
        }),
        'Invalid JSON (line 1, column 2).',
      );
    });

    test('requires JSON unless the field is nullable', () {
      expect(
        validateFieldValue(_field(ResourceFieldType.jsonMap), null),
        'Value is required.',
      );
      expect(
        validateFieldValue(
          _field(ResourceFieldType.jsonMap, nullable: true),
          null,
        ),
        isNull,
      );
    });
  });

  group('fieldValueEquals', () {
    test('compares maps and lists by content', () {
      expect(
        fieldValueEquals(
          {
            'a': [
              1,
              {'b': true},
            ],
          },
          {
            'a': [
              1,
              {'b': true},
            ],
          },
        ),
        isTrue,
      );
      expect(fieldValueEquals([1, 2], [2, 1]), isFalse);
      expect(fieldValueEquals({'a': 1}, [1]), isFalse);
    });

    test('compares other values with ==', () {
      expect(fieldValueEquals('a', 'a'), isTrue);
      expect(fieldValueEquals(1, 2), isFalse);
      expect(fieldValueEquals(null, null), isTrue);
    });
  });

  group('decodeFieldData', () {
    test('decodes the elements of typed lists', () {
      const point = Point(4326, 13.4, 52.5);
      final data = ResourceData(
        id: '1',
        fieldData: {
          'dates': [_timestamp],
          'files': ['AQID'],
          'locations': [base64Encode(point.toEWKB())],
          'names': ['a'],
        },
      );

      decodeFieldData(
        _resource([
          _list('dates', ResourceFieldType.timestamp),
          _list('files', ResourceFieldType.bytes),
          _list('locations', ResourceFieldType.geometry),
          _list('names', ResourceFieldType.string),
        ]),
        data,
      );

      expect(data.fieldData['dates'], [_dateTime]);
      expect(data.fieldData['files'], [
        isA<Uint8List>().having((e) => e.toList(), 'bytes', [1, 2, 3]),
      ]);
      expect(data.fieldData['locations'], [point]);
      expect(data.fieldData['names'], ['a']);
    });

    test('decodes the fields of objects and of list elements', () {
      const period = [
        ResourceField(
          id: 'start',
          name: 'Start',
          type: ResourceFieldType.timestamp,
        ),
      ];
      final data = ResourceData(
        id: '1',
        fieldData: {
          'period': {'start': _timestamp, 'unknown': _timestamp},
          'periods': [
            {'start': _timestamp},
          ],
        },
      );

      decodeFieldData(
        _resource([
          const ResourceField(
            id: 'period',
            name: 'Period',
            type: ResourceFieldType.object,
            objectDescription: period,
          ),
          _list('periods', ResourceFieldType.object, period),
        ]),
        data,
      );

      expect(data.fieldData['period'], {
        'start': _dateTime,
        'unknown': _timestamp,
      });
      expect(data.fieldData['periods'], [
        {'start': _dateTime},
      ]);
    });

    test('keeps JSON as it is', () {
      final data = ResourceData(
        id: '1',
        fieldData: {
          'settings': {
            'dates': [_timestamp],
          },
        },
      );

      decodeFieldData(
        _resource([
          const ResourceField(
            id: 'settings',
            name: 'Settings',
            type: ResourceFieldType.jsonMap,
          ),
        ]),
        data,
      );

      expect(data.fieldData['settings'], {
        'dates': [_timestamp],
      });
    });

    test('names the element that does not decode', () {
      final data = ResourceData(
        id: '1',
        fieldData: {
          'dates': [_timestamp, 'tomorrow'],
        },
      );

      expect(
        () => decodeFieldData(
          _resource([_list('dates', ResourceFieldType.timestamp)]),
          data,
        ),
        throwsA(
          isA<CodecException>().having((e) => e.name, 'name', 'dates[1]'),
        ),
      );
    });
  });
}
