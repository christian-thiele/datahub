import 'package:datahub/utils.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_element_edit_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = ResourceField(
  id: 'id',
  name: 'Id',
  type: ResourceFieldType.int,
  readOnly: true,
);
const _numbers = ResourceField(
  id: 'numbers',
  name: 'Numbers',
  type: ResourceFieldType.list,
  objectDescription: [
    ResourceField(id: 'element', name: '', type: ResourceFieldType.int),
  ],
);
const _name = ResourceField(
  id: 'name',
  name: 'Name',
  type: ResourceFieldType.string,
);
const _updated = ResourceField(
  id: 'updated',
  name: 'Updated',
  type: ResourceFieldType.timestamp,
);
const _file = ResourceField(
  id: 'file',
  name: 'File',
  type: ResourceFieldType.bytes,
);

/// Serves the current version of an element and an older revision as raw
/// JSON values, like the API does, and fails to save with [saveError].
class _Repository implements ResourcesRepository {
  final List<ResourceField> fields;
  final Map<String, dynamic> current;
  final Map<String, dynamic> revision;
  final Object? saveError;

  _Repository({
    this.fields = const [_name, _updated, _file],
    required this.current,
    this.revision = const {},
    this.saveError,
  });

  @override
  Future<ResourceDescription> getDescription(String id) async =>
      ResourceDescription(
        id: id,
        name: 'Example',
        icon: 0,
        fields: fields,
        relations: const [],
        idField: 'id',
        readOnly: false,
        revisable: true,
        actions: const [],
      );

  @override
  Future<ResourceData> getResourceElement(
    String resourceId,
    String elementId, {
    int? version,
  }) async => ResourceData(
    id: elementId,
    fieldData: {...version == null ? current : revision},
  );

  @override
  Future<ResourceData> updateElement(
    String resourceId,
    String elementId,
    Map<String, dynamic> changes,
    DateTime? from,
  ) async => throw saveError!;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A field error as the client throws it for the backend's response.
ApiRequestException _fieldError(String path) {
  final message =
      'Mismatching types for property "$path": Expected int but received '
      'Null.';
  return ApiRequestException.fromResponse(400, {
    'statusCode': 400,
    'errorMessage': message,
    'fields': {
      path: [message],
    },
  });
}

/// Opens the current version of an element.
Future<ResourceElementEditCubit> _open(_Repository repository) async {
  final cubit = ResourceElementEditCubit(
    repository,
    resourceId: 'Example',
    elementId: '1',
  );
  addTearDown(cubit.close);

  await cubit.stream.firstWhere(
    (state) => state is! ResourceElementEditLoading,
  );
  return cubit;
}

/// Opens the current version of an element to revert it to its revision.
Future<ResourceElementEditValue> _revert(_Repository repository) async {
  final cubit = ResourceElementEditCubit(
    repository,
    resourceId: 'Example',
    elementId: '1',
    revertFromVersion: 1,
  );
  addTearDown(cubit.close);

  final state = await cubit.stream.firstWhere(
    (state) => state is! ResourceElementEditLoading,
  );
  return state as ResourceElementEditValue;
}

void main() {
  group('reverting to a revision', () {
    test('changes only the fields that differ', () async {
      final state = await _revert(
        _Repository(
          current: {
            'name': 'New',
            'updated': '2026-01-02T03:04:05Z',
            'file': 'AQID',
          },
          revision: {
            'name': 'Old',
            'updated': '2026-01-02T03:04:05Z',
            'file': 'AQID',
          },
        ),
      );

      expect(state.changes, {_name: 'Old'});
    });

    test('changes fields to decoded values', () async {
      final state = await _revert(
        _Repository(
          current: {
            'name': 'Same',
            'updated': '2026-01-02T03:04:05Z',
            'file': 'AQID',
          },
          revision: {
            'name': 'Same',
            'updated': '2025-06-07T08:09:10Z',
            'file': 'AQID',
          },
        ),
      );

      expect(state.changes, {_updated: DateTime.utc(2025, 6, 7, 8, 9, 10)});
    });
  });

  group('saving', () {
    setUpAll(() => S.load(const Locale('en')));

    /// Saves a list with an empty element, which the backend rejects with
    /// [error].
    Future<ResourceElementEditCubit> saveNumbers(Object error) async {
      final cubit = await _open(
        _Repository(
          fields: const [_id, _numbers],
          current: {
            'id': 1,
            'numbers': [1],
          },
          saveError: error,
        ),
      );
      cubit.setFieldValue('numbers', [1, null]);
      await cubit.saveChanges();
      return cubit;
    }

    test('keeps errors of list elements for the elements', () async {
      final cubit = await saveNumbers(_fieldError('numbers[1]'));

      final state = cubit.state as ResourceElementEditValue;
      expect(state, isNot(isA<ResourceElementEditSaving>()));
      expect(state.validations, {
        'numbers[1]':
            'Mismatching types for property "numbers[1]": Expected int but '
            'received Null.',
      });
      expect(state.changes, {
        _numbers: [1, null],
      });
    });

    test('forgets the errors of a field when it changes', () async {
      final cubit = await saveNumbers(_fieldError('numbers[1]'));

      cubit.setFieldValue('numbers', [1, 2]);

      expect((cubit.state as ResourceElementEditValue).validations, isEmpty);
    });

    test('fails for errors of values that can not be edited', () async {
      for (final path in ['id', 'unknown[0]']) {
        final cubit = await saveNumbers(_fieldError(path));

        expect(cubit.state, isA<ResourceElementEditError>(), reason: path);
      }
    });
  });
}
