import 'package:datahub/utils.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_action_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
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

/// Records the parameters actions are run with, failing with [error] if
/// given.
class _Runner {
  final Object? error;
  final runs = <Map<String, dynamic>>[];

  _Runner([this.error]);

  Future<void> call(Map<String, dynamic> parameters) async {
    runs.add(parameters);
    if (error case final error?) {
      throw error;
    }
  }
}

ResourceActionCubit _cubit(
  _Runner runner,
  ResourceAction action, {
  Map<String, dynamic> initialValues = const {},
}) {
  final cubit = ResourceActionCubit(
    action: action,
    run: runner.call,
    initialValues: initialValues,
  );
  addTearDown(cubit.close);
  return cubit;
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('starts actions without parameters right away', () async {
    final runner = _Runner();
    final cubit = _cubit(
      runner,
      const ResourceAction(
        id: 'Archive',
        displayName: 'Archive',
        icon: 0,
        parameterFields: [],
      ),
    );

    await cubit.stream.firstWhere((state) => state is ResourceActionDone);
    expect(runner.runs, [<String, dynamic>{}]);
  });

  test('waits for the parameters to be filled in', () async {
    final runner = _Runner();
    final cubit = _cubit(runner, _resolve);

    final state = cubit.state as ResourceActionEditing;
    expect(state.values, {'closeImmediately': false});
    expect(state.validation, isEmpty);
    expect(runner.runs, isEmpty);
  });

  test('fills in the initial values', () async {
    final runner = _Runner();
    final cubit = _cubit(
      runner,
      _resolve,
      initialValues: {'reference': 'T-1', 'closeImmediately': true},
    );

    final state = cubit.state as ResourceActionEditing;
    expect(state.values, {'closeImmediately': true, 'reference': 'T-1'});
    expect(runner.runs, isEmpty);
  });

  test('does not start with missing parameters', () async {
    final runner = _Runner();
    final cubit = _cubit(runner, _resolve);

    await cubit.start();

    final state = cubit.state as ResourceActionEditing;
    expect(state.validation.keys, ['resolution']);
    expect(runner.runs, isEmpty);
  });

  test('starts with the parameters filled in', () async {
    final runner = _Runner();
    final cubit = _cubit(runner, _resolve);

    cubit.setParameterValue(_resolution, 'Replaced the router.');
    await cubit.start();

    expect(cubit.state, isA<ResourceActionDone>());
    expect(runner.runs, [
      {'closeImmediately': false, 'resolution': 'Replaced the router.'},
    ]);
  });

  test('shows parameter errors of the backend at the parameters', () async {
    final runner = _Runner(
      ApiRequestException.fromResponse(400, {
        'statusCode': 400,
        'errorMessage': 'Invalid values for fields: resolution',
        'fields': {
          'resolution': ['Too short.'],
        },
      }),
    );
    final cubit = _cubit(runner, _resolve);

    cubit.setParameterValue(_resolution, 'Done.');
    await cubit.start();

    final state = cubit.state as ResourceActionEditing;
    expect(state.validation, {'resolution': 'Too short.'});
    expect(state.values['resolution'], 'Done.');
  });
}
