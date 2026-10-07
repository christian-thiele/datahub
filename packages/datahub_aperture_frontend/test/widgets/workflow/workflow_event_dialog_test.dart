import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/workflow/workflow_event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../_utils/fake_workflow_repository.dart';

/// Opens the dialog of [event] and returns what it closed with, once it is
/// closed.
Future<Future<bool>> _open(
  WidgetTester tester,
  FakeWorkflowRepository repository,
  ResourceWorkflowEvent event,
) async {
  late Future<bool> result;
  await tester.pumpWidget(
    RepositoryProvider<WorkflowRepository>.value(
      value: repository,
      child: MaterialApp(
        theme: ApertureThemeData.defaultTheme,
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => result = WorkflowEventDialog.show(
                context,
                resourceId: 'Invoice',
                event: event,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
    await initializeDateFormatting();
  });

  testWidgets('retries a parked event and shows its error and log', (
    tester,
  ) async {
    final event = workflowEvent(
      'e1',
      status: WorkflowEventStatus.failed,
      attempts: 3,
      lastError: 'The mail server rejected the reminder.',
      messages: [
        '{"timestamp":"2026-10-01T12:00:00.000Z","severity":"info",'
            '"msg":"Sending a payment reminder."}',
      ],
    );
    final repository = FakeWorkflowRepository(events: [event]);
    await _open(tester, repository, event);

    expect(find.text('The mail server rejected the reminder.'), findsWidgets);
    expect(find.text('Sending a payment reminder.'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.retried, ['e1']);
  });

  testWidgets('can not change an event that is being handled', (tester) async {
    final event = workflowEvent('e1', running: true);
    await _open(tester, FakeWorkflowRepository(events: [event]), event);

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Discard'), findsNothing);
  });

  testWidgets('discards a waiting event once confirmed', (tester) async {
    final event = workflowEvent(
      'e1',
      dueAt: DateTime.now().add(const Duration(days: 1)),
    );
    final repository = FakeWorkflowRepository(events: [event]);
    final result = await _open(tester, repository, event);
    expect(find.text('Retry'), findsNothing);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(repository.cancelled, isEmpty, reason: 'not confirmed yet');

    // The button of the confirmation.
    await tester.tap(find.text('Discard').last);
    await tester.pumpAndSettle();
    expect(repository.cancelled, ['e1']);
    expect(await result, isTrue);
    expect(find.byType(WorkflowEventDialog), findsNothing);
  });

  testWidgets('shows why an event could not be changed', (tester) async {
    final event = workflowEvent('e1', status: WorkflowEventStatus.expired);
    final repository = FakeWorkflowRepository(events: [event])
      ..error = ApiRequestException.fromResponse(409, {
        'statusCode': 409,
        'errorMessage': 'The workflow event is being handled.',
      });
    await _open(tester, repository, event);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('The workflow event is being handled.'), findsOneWidget);
  });
}
