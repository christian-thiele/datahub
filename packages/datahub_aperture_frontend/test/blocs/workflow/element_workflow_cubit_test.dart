import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/blocs/workflow/element_workflow_cubit.dart';
import 'package:datahub_aperture_frontend/blocs/workflow/workflow_polling.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_utils/fake_workflow_repository.dart';

final _now = DateTime.utc(2026, 10, 1, 12);

ElementWorkflowCubit _cubit(
  FakeWorkflowRepository repository, {
  bool writesHistory = true,
  void Function()? onElementChanged,
}) => ElementWorkflowCubit(
  repository,
  resourceId: 'Invoice',
  elementId: '1',
  writesHistory: writesHistory,
  onElementChanged: onElementChanged,
  now: () => _now,
);

Future<ElementWorkflowValue> _loaded(ElementWorkflowCubit cubit) async {
  final state = switch (cubit.state) {
    final ElementWorkflowValue state => state,
    _ => await cubit.stream.firstWhere(
      (state) => state is ElementWorkflowValue,
    ),
  };
  return state as ElementWorkflowValue;
}

void main() {
  group('workflowPollDelay', () {
    test('does not poll without pending events', () {
      expect(workflowPollDelay([], _now), isNull);
      expect(
        workflowPollDelay([
          workflowEvent('1', status: WorkflowEventStatus.failed),
          workflowEvent('2', status: WorkflowEventStatus.expired),
        ], _now),
        isNull,
      );
    });

    test('polls soon while an event is running or due', () {
      expect(
        workflowPollDelay([workflowEvent('1', running: true)], _now),
        workflowFastPoll,
      );
      expect(
        workflowPollDelay([workflowEvent('1', dueAt: _now)], _now),
        workflowFastPoll,
      );
    });

    test('polls when the next event is due, at most every minute', () {
      Duration? delayFor(Duration untilDue) => workflowPollDelay([
        workflowEvent('1', dueAt: _now.add(untilDue)),
        workflowEvent('2', dueAt: _now.add(const Duration(days: 1))),
      ], _now);

      expect(delayFor(const Duration(seconds: 1)), workflowFastPoll);
      expect(
        delayFor(const Duration(seconds: 30)),
        const Duration(seconds: 30),
      );
      expect(delayFor(const Duration(hours: 1)), workflowSlowPoll);
    });
  });

  group('ElementWorkflowCubit', () {
    test('loads the events and the history', () async {
      final repository = FakeWorkflowRepository(
        events: [
          workflowEvent('e1', status: WorkflowEventStatus.failed),
          workflowEvent('e2', elementId: '2'),
        ],
        history: [
          historyEntry('h2', WorkflowHistoryKind.stepFailed, step: 'sent'),
          historyEntry('h1', WorkflowHistoryKind.started, state: 'sent'),
        ],
      );
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      final state = await _loaded(cubit);
      expect(state.events.map((e) => e.event.id), ['e1']);
      expect(state.history.map((e) => e.id), ['h2', 'h1']);
      expect(state.hasMoreHistory, isFalse);
    });

    test('does not load the history if it is not written', () async {
      final repository = FakeWorkflowRepository();
      final cubit = _cubit(repository, writesHistory: false);
      addTearDown(cubit.close);

      final state = await _loaded(cubit);
      expect(state.history, isEmpty);
      expect(repository.historyLoads, 0);
    });

    test('loads more of the history', () async {
      final repository = FakeWorkflowRepository(
        history: [
          for (var i = 30; i > 0; i--)
            historyEntry('h$i', WorkflowHistoryKind.stepSucceeded),
        ],
      );
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      final first = await _loaded(cubit);
      expect(first.history, hasLength(ElementWorkflowCubit.historyPageSize));
      expect(first.hasMoreHistory, isTrue);

      await cubit.loadMoreHistory();
      final all = cubit.state as ElementWorkflowValue;
      expect(all.history.map((e) => e.id).toSet(), hasLength(30));
      expect(all.hasMoreHistory, isFalse);

      // Reloads keep what was loaded.
      await cubit.reload();
      expect((cubit.state as ElementWorkflowValue).history, hasLength(30));
    });

    test('resumes the element and reloads', () async {
      final repository = FakeWorkflowRepository();
      final cubit = _cubit(repository);
      addTearDown(cubit.close);
      await _loaded(cubit);

      repository.events = [
        workflowEvent('e1', status: WorkflowEventStatus.failed),
      ];
      await cubit.resume();

      expect(repository.resumed, ['1']);
      expect((cubit.state as ElementWorkflowValue).events, hasLength(1));
    });

    test('tells when the workflow changed the element', () async {
      final repository = FakeWorkflowRepository(
        events: [workflowEvent('e1', status: WorkflowEventStatus.failed)],
        history: [historyEntry('h1', WorkflowHistoryKind.started)],
      );
      var changes = 0;
      final cubit = _cubit(repository, onElementChanged: () => changes++);
      addTearDown(cubit.close);
      await _loaded(cubit);

      await cubit.reload();
      expect(changes, 0, reason: 'nothing happened');

      repository.history = [
        historyEntry('h2', WorkflowHistoryKind.signalReceived),
        ...repository.history,
      ];
      await cubit.reload();
      expect(changes, 1, reason: 'a new history entry');

      repository.events = [];
      await cubit.reload();
      expect(changes, 2, reason: 'the event is gone');
    });

    testWidgets('polls while events are pending', (tester) async {
      final repository = FakeWorkflowRepository(
        events: [workflowEvent('e1', running: true)],
      );
      var changes = 0;
      final cubit = _cubit(
        repository,
        writesHistory: false,
        onElementChanged: () => changes++,
      );
      await tester.pump();
      expect(repository.eventLoads, 1);

      await tester.pump(workflowFastPoll);
      expect(repository.eventLoads, 2);

      // The step finished: the element changed and nothing is pending.
      repository.events = [];
      await tester.pump(workflowFastPoll);
      expect(repository.eventLoads, 3);
      expect(changes, 1);

      await tester.pump(const Duration(minutes: 10));
      expect(repository.eventLoads, 3);

      repository.events = [workflowEvent('e2', running: true)];
      await cubit.reload();
      await cubit.close();
      await tester.pump(const Duration(minutes: 10));
      expect(repository.eventLoads, 4, reason: 'no polls after close');
    });
  });
}
