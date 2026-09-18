import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_element_edit_cubit.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:flutter_test/flutter_test.dart';

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
/// JSON values, like the API does.
class _Repository implements ResourcesRepository {
  final Map<String, dynamic> current;
  final Map<String, dynamic> revision;

  _Repository({required this.current, required this.revision});

  @override
  Future<ResourceDescription> getDescription(String id) async =>
      ResourceDescription(
        id: id,
        name: 'Example',
        icon: 0,
        fields: const [_name, _updated, _file],
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
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
}
