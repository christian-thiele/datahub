import 'package:datahub/utils.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_action_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _resolution = ResourceField(
  id: 'resolution',
  name: 'Resolution',
  type: ResourceFieldType.string,
);
const _closeImmediately = ResourceField(
  id: 'closeImmediately',
  name: 'Close immediately',
  type: ResourceFieldType.bool,
);
const _reference = ResourceField(
  id: 'reference',
  name: 'Reference',
  type: ResourceFieldType.string,
  nullable: true,
);

const _resolve = ResourceAction(
  id: 'ResolveTicket',
  displayName: 'Resolve ticket',
  icon: 0,
  parameterFields: [_resolution, _closeImmediately, _reference],
);

/// Records the parameters actions are started with, failing with [error] if
/// given.
class _Repository implements ResourcesRepository {
  final Object? error;
  final started = <Map<String, dynamic>>[];

  _Repository([this.error]);

  @override
  Future<Map<String, dynamic>> startElementAction(
    String resourceId,
    String elementId,
    String actionId,
    Map<String, dynamic> parameters,
  ) async {
    started.add(parameters);
    if (error case final error?) {
      throw error;
    }
    return {};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ResourceActionCubit _cubit(_Repository repository, ResourceAction action) {
  final cubit = ResourceActionCubit(
    repository,
    resourceId: 'SupportTicket',
    action: action,
    elementId: '1',
  );
  addTearDown(cubit.close);
  return cubit;
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('starts actions without parameters right away', () async {
    final repository = _Repository();
    final cubit = _cubit(
      repository,
      const ResourceAction(
        id: 'Archive',
        displayName: 'Archive',
        icon: 0,
        parameterFields: [],
      ),
    );

    await cubit.stream.firstWhere((state) => state is ResourceActionDone);
    expect(repository.started, [<String, dynamic>{}]);
  });

  test('waits for the parameters to be filled in', () async {
    final repository = _Repository();
    final cubit = _cubit(repository, _resolve);

    final state = cubit.state as ResourceActionEditing;
    expect(state.values, {'closeImmediately': false});
    expect(state.validation, isEmpty);
    expect(repository.started, isEmpty);
  });

  test('does not start with missing parameters', () async {
    final repository = _Repository();
    final cubit = _cubit(repository, _resolve);

    await cubit.start();

    final state = cubit.state as ResourceActionEditing;
    expect(state.validation.keys, ['resolution']);
    expect(repository.started, isEmpty);
  });

  test('starts with the parameters filled in', () async {
    final repository = _Repository();
    final cubit = _cubit(repository, _resolve);

    cubit.setParameterValue(_resolution, 'Replaced the router.');
    await cubit.start();

    expect(cubit.state, isA<ResourceActionDone>());
    expect(repository.started, [
      {'closeImmediately': false, 'resolution': 'Replaced the router.'},
    ]);
  });

  test('shows parameter errors of the backend at the parameters', () async {
    final repository = _Repository(
      ApiRequestException.fromResponse(400, {
        'statusCode': 400,
        'errorMessage': 'Invalid values for fields: resolution',
        'fields': {
          'resolution': ['Too short.'],
        },
      }),
    );
    final cubit = _cubit(repository, _resolve);

    cubit.setParameterValue(_resolution, 'Done.');
    await cubit.start();

    final state = cubit.state as ResourceActionEditing;
    expect(state.validation, {'resolution': 'Too short.'});
    expect(state.values['resolution'], 'Done.');
  });
}
