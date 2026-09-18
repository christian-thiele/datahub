import 'package:datahub/utils.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_element_create_cubit.dart';
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

/// Fails to create elements with [saveError].
class _Repository implements ResourcesRepository {
  final Object saveError;

  _Repository(this.saveError);

  @override
  Future<ResourceDescription> getDescription(String id) async =>
      ResourceDescription(
        id: id,
        name: 'Example',
        icon: 0,
        fields: const [_id, _numbers],
        relations: const [],
        idField: 'id',
        readOnly: false,
        revisable: false,
        actions: const [],
      );

  @override
  Future<ResourceData> createElement(
    String resourceId,
    Map<String, dynamic> changes,
    DateTime? from,
  ) async => throw saveError;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A field error as the client throws it for the backend's response.
ApiRequestException _fieldError(String path, String message) =>
    ApiRequestException.fromResponse(400, {
      'statusCode': 400,
      'errorMessage': message,
      'fields': {
        path: [message],
      },
    });

/// Creates an element with a list with an empty element, which the backend
/// rejects with [error].
Future<ResourceElementCreateCubit> _saveNumbers(Object error) async {
  final cubit = ResourceElementCreateCubit(
    _Repository(error),
    resourceId: 'Example',
  );
  addTearDown(cubit.close);

  await cubit.stream.firstWhere(
    (state) => state is ResourceElementCreateEditing,
  );
  cubit.setFieldValue('numbers', [1, null]);
  await cubit.saveChanges();
  return cubit;
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('keeps errors of list elements for the elements', () async {
    final cubit = await _saveNumbers(
      _fieldError('numbers[1]', 'Expected int but received Null.'),
    );

    final state = cubit.state as ResourceElementCreateEditing;
    expect(state.validation, {'numbers[1]': 'Expected int but received Null.'});
    expect(state.changes, {
      _numbers: [1, null],
    });
  });

  test('fails for errors of values that can not be edited', () async {
    final cubit = await _saveNumbers(_fieldError('id', 'Already taken.'));

    expect(cubit.state, isA<ResourceElementCreateError>());
  });
}
