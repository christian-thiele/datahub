import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/pages/resource_element_edit/resource_element_edit_view.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

const _workflow = Text('the workflow panel');

/// Shows the view of an element, with revisions if it is [revisable] and
/// with [workflow].
Future<void> _pumpView(
  WidgetTester tester, {
  required bool revisable,
  Widget? workflow,
  double width = 1400,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final data = ResourceData(
    id: '1',
    fieldData: const {},
    version: revisable ? 1 : null,
    revisions: [
      if (revisable)
        ResourceRevisionInfo(
          version: 1,
          type: ResourceRevisionType.create,
          timestamp: DateTime.utc(2026, 10, 1),
          live: DateTime.utc(2026, 10, 1),
          userId: 'demo',
          userName: 'Demo',
        ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(
      theme: ApertureThemeData.defaultTheme,
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ResourceElementEditView(
                title: 'INV-2026-0001',
                fields: const [],
                data: data,
                changes: const {},
                onFieldValueChanged: (_, _) {},
                onSavePressed: null,
                actions: const [],
                revisable: revisable,
                workflow: workflow,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
    await initializeDateFormatting();
  });

  for (final (layout, width) in [('wide', 1400.0), ('narrow', 800.0)]) {
    testWidgets('switches between revisions and workflow ($layout)', (
      tester,
    ) async {
      await _pumpView(
        tester,
        revisable: true,
        workflow: _workflow,
        width: width,
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Revision History'), findsOneWidget);
      expect(find.text('the workflow panel'), findsNothing);

      await tester.tap(find.text('Workflow'));
      await tester.pumpAndSettle();
      expect(find.text('the workflow panel'), findsOneWidget);
      expect(find.text('Revision History'), findsNothing);
    });
  }

  testWidgets('shows the workflow alone without tabs', (tester) async {
    await _pumpView(tester, revisable: false, workflow: _workflow);

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('the workflow panel'), findsOneWidget);
  });

  testWidgets('shows the revisions alone without tabs', (tester) async {
    await _pumpView(tester, revisable: true);

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Revision History'), findsOneWidget);
  });
}
