import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/pages/resource_element_edit/element_action_dialog.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../_utils/fake_workflow_repository.dart';

const _markPaid = ResourceAction(
  id: 'MarkInvoicePaid',
  displayName: 'Mark as paid',
  icon: 0xe481,
  parameterFields: [
    ResourceField(
      id: 'paidAt',
      name: 'Payment received',
      type: ResourceFieldType.timestamp,
    ),
    ResourceField(
      id: 'paymentReference',
      name: 'Payment reference',
      type: ResourceFieldType.string,
      nullable: true,
    ),
  ],
);

/// Records the parameters actions are started with, responding with
/// [result].
class _Repository implements ResourcesRepository {
  final ResourceActionResult result;
  final started = <Map<String, dynamic>>[];

  _Repository([this.result = const ResourceActionResult()]);

  @override
  Future<ResourceActionResult> startElementAction(
    String resourceId,
    String elementId,
    String actionId,
    Map<String, dynamic> parameters,
  ) async {
    started.add(parameters);
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pumpDialog(WidgetTester tester, _Repository repository) async {
  await tester.pumpWidget(
    RepositoryProvider<ResourcesRepository>.value(
      value: repository,
      child: MaterialApp(
        theme: ApertureThemeData.defaultTheme,
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(
          body: ElementActionDialog(
            resourceId: 'Invoice',
            elementId: '1',
            action: _markPaid,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
    await initializeDateFormatting();
  });

  testWidgets('asks for the parameters before starting', (tester) async {
    final repository = _Repository();
    await _pumpDialog(tester, repository);

    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('Payment reference'), findsOneWidget);
    expect(repository.started, isEmpty);
  });

  testWidgets('does not start without required parameters', (tester) async {
    final repository = _Repository();
    await _pumpDialog(tester, repository);

    await tester.tap(find.text('Run'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Value is required.'), findsOneWidget);
    expect(repository.started, isEmpty);
  });

  testWidgets('sends a signal with the values filled in', (tester) async {
    final workflows = FakeWorkflowRepository();
    await tester.pumpWidget(
      RepositoryProvider<WorkflowRepository>.value(
        value: workflows,
        child: MaterialApp(
          theme: ApertureThemeData.defaultTheme,
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: const Scaffold(
            body: ElementActionDialog.signal(
              resourceId: 'Invoice',
              elementId: '7',
              action: ResourceAction(
                id: 'CancelInvoice',
                displayName: 'Cancel invoice',
                icon: 0,
                parameterFields: [
                  ResourceField(
                    id: 'invoiceId',
                    name: 'Invoice',
                    type: ResourceFieldType.int,
                  ),
                ],
              ),
              initialValues: {'invoiceId': 7},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    final (elementId, signalId, payload) = workflows.signals.single;
    expect(elementId, '7');
    expect(signalId, 'CancelInvoice');
    expect(payload, {'invoiceId': 7});
    expect(find.textContaining('Signal sent.'), findsOneWidget);
  });

  group('result', () {
    const archive = ResourceAction(
      id: 'Archive',
      displayName: 'Archive',
      icon: 0,
      parameterFields: [],
    );

    Future<void> pumpArchive(WidgetTester tester, _Repository repository) =>
        tester.pumpWidget(
          RepositoryProvider<ResourcesRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: ApertureThemeData.defaultTheme,
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: ElementActionDialog(
                  resourceId: 'Invoice',
                  elementId: '1',
                  action: archive,
                ),
              ),
            ),
          ),
        );

    testWidgets('confirms an action without a message', (tester) async {
      await pumpArchive(tester, _Repository());
      await tester.pumpAndSettle();

      expect(find.text('Action completed.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows the message and data', (tester) async {
      await pumpArchive(
        tester,
        _Repository(
          const ResourceActionResult(
            message: 'Archived 2 invoices.',
            data: {
              'invoices': ['INV-1', 'INV-2'],
              'total': 1200.5,
              'details': {'archive': 'cold'},
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Archived 2 invoices.'), findsOneWidget);
      expect(find.text('invoices'), findsOneWidget);
      expect(find.text('INV-1, INV-2'), findsOneWidget);
      expect(find.text('1200.5'), findsOneWidget);
      expect(find.textContaining('"archive": "cold"'), findsOneWidget);
    });

    testWidgets('shows failures', (tester) async {
      await pumpArchive(
        tester,
        _Repository(
          const ResourceActionResult(
            success: false,
            message: 'The invoice is not paid yet.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The invoice is not paid yet.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('opens the element it redirects to', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const ElementActionDialog(
                      resourceId: 'Invoice',
                      elementId: '1',
                      action: archive,
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/resources/:resourceId/view/:elementId',
            builder: (context, state) => Text(
              'Element ${state.pathParameters['resourceId']} '
              '${state.pathParameters['elementId']}',
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        RepositoryProvider<ResourcesRepository>.value(
          value: _Repository(
            const ResourceActionResult(
              redirect: ResourceActionRedirect(
                resourceId: 'Archive Entry',
                elementId: '7',
              ),
            ),
          ),
          child: MaterialApp.router(
            theme: ApertureThemeData.defaultTheme,
            localizationsDelegates: const [S.delegate],
            supportedLocales: S.delegate.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(ElementActionDialog), findsNothing);
      expect(find.text('Element Archive Entry 7'), findsOneWidget);
    });
  });
}
