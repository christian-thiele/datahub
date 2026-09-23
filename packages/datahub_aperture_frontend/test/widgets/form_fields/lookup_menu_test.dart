import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_utils/lookup_repository.dart';

const _owner = ResourceField(
  id: 'ownerId',
  name: 'Owner',
  type: ResourceFieldType.int,
  nullable: true,
  lookup: ResourceFieldLookup(
    resourceId: 'Person',
    resourceFieldId: 'id',
    filter: ResourceRelationFilter(),
  ),
);

final _people = LookupRepository(people, [
  {'id': 7, 'name': 'Grace'},
  {'id': 42, 'name': 'Ada'},
]);

/// Holds the value of a field like the form does, and records the values the
/// field emits.
class _Host extends StatefulWidget {
  final ResourceField field;
  final dynamic initialValue;
  final List<dynamic> emitted;

  const _Host({
    required this.field,
    required this.initialValue,
    required this.emitted,
  });

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late dynamic value = widget.initialValue;

  @override
  Widget build(BuildContext context) => ResourceFormField(
    field: widget.field,
    path: widget.field.id,
    value: value,
    onChanged: (v) => setState(() {
      widget.emitted.add(v);
      value = v;
    }),
  );
}

/// Pumps [field] with [value], waits for the linked element and returns the
/// values the field emits.
Future<List<dynamic>> _pump(
  WidgetTester tester, {
  ResourceField field = _owner,
  dynamic value,
  ResourcesRepository? repository,
}) async {
  final emitted = [];
  await tester.pumpWidget(
    RepositoryProvider<ResourcesRepository>.value(
      value: repository ?? _people,
      child: MaterialApp(
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              // Above the field, where the menu does not cover it.
              const TextField(key: Key('other')),
              _Host(field: field, initialValue: value, emitted: emitted),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return emitted;
}

Finder get _lookupField => find.descendant(
  of: find.byType(ResourceFormField),
  matching: find.byType(TextField),
);

TextField _field(WidgetTester tester) => tester.widget<TextField>(_lookupField);

String? _title(WidgetTester tester) =>
    switch (_field(tester).decoration?.prefix) {
      Text(:final data) => data,
      _ => null,
    };

bool _isValueHidden(WidgetTester tester) =>
    _field(tester).style?.color == Colors.transparent;

IconData? _linkIcon(WidgetTester tester) =>
    switch (_field(tester).decoration?.suffixIcon) {
      Icon(:final icon) ||
      Tooltip(child: Icon(:final icon)) ||
      Material(child: InkWell(child: Icon(:final icon))) => icon,
      _ => null,
    };

void main() {
  testWidgets('shows the title of the linked element instead of the value', (
    tester,
  ) async {
    await _pump(tester, value: 42);

    expect(_title(tester), 'Ada');
    expect(_isValueHidden(tester), isTrue);
    expect(_linkIcon(tester), Icons.link);
  });

  testWidgets('shows the value while it is edited', (tester) async {
    await _pump(tester, value: 42);

    await tester.tap(_lookupField);
    await tester.pump();

    expect(_title(tester), isNull);
    expect(_isValueHidden(tester), isFalse);
  });

  testWidgets('shows the title of a value entered once editing ends', (
    tester,
  ) async {
    final emitted = await _pump(tester);

    await tester.tap(_lookupField);
    await tester.enterText(_lookupField, '7');
    await tester.pump();
    expect(emitted, [7]);
    expect(_title(tester), isNull);

    await tester.tap(find.byKey(const Key('other')));
    await tester.pumpAndSettle();
    expect(_title(tester), 'Grace');
    expect(_linkIcon(tester), Icons.link);
  });

  testWidgets('shows the title of an element picked from the menu at once', (
    tester,
  ) async {
    const delay = Duration(seconds: 1);
    final emitted = await _pump(
      tester,
      value: 7,
      repository: LookupRepository(people, [
        {'id': 7, 'name': 'Grace'},
        {'id': 42, 'name': 'Ada'},
      ], delay: delay),
    );
    await tester.pump(delay);
    expect(_title(tester), 'Grace');

    await tester.tap(_lookupField);
    await tester.pump();
    await tester.pump(delay);
    await tester.tap(find.text('Ada'));
    await tester.pump();

    expect(emitted, [42]);
    expect(_title(tester), 'Ada');
    expect(_linkIcon(tester), Icons.link);

    // The menu still searches for the value that was set.
    await tester.pumpAndSettle(delay);
  });

  testWidgets(
    'does not blur the field while a mouse click on an element is held down',
    (tester) async {
      // On desktop, an EditableText unfocuses on the pointer-down of a tap
      // outside it, well before the tap on the element is recognized (which
      // needs pointer-up). Without the menu sharing the field's tap region,
      // that would end editing (and reload the old link) before the pick.
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      final emitted = await _pump(tester, value: 7);
      await tester.tap(_lookupField);
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Ada')),
      );
      addTearDown(() => gesture.removePointer());
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          _field(tester).focusNode?.hasFocus,
          isTrue,
          reason: 'the field should not blur while the mouse is held down',
        );
        expect(emitted, isEmpty);
      }

      await gesture.up();
      await tester.pump();

      expect(emitted, [42]);
      expect(_title(tester), 'Ada');
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('hints that a value links to nothing', (tester) async {
    await _pump(tester, value: 99);

    expect(_title(tester), isNull);
    expect(_isValueHidden(tester), isFalse);
    expect(_linkIcon(tester), Icons.link_off);
    expect(find.byTooltip('Linked element not found'), findsOneWidget);
  });

  testWidgets('hints that an empty field links to nothing', (tester) async {
    final repository = LookupRepository(people, []);
    await _pump(tester, repository: repository);

    expect(_linkIcon(tester), Icons.link_off);
    expect(repository.filters, isEmpty);
  });

  testWidgets('shows titles for text fields as well', (tester) async {
    await _pump(
      tester,
      field: const ResourceField(
        id: 'teamId',
        name: 'Team',
        type: ResourceFieldType.string,
        lookup: ResourceFieldLookup(
          resourceId: 'Team',
          resourceFieldId: 'id',
          filter: ResourceRelationFilter(),
        ),
      ),
      value: 'core',
      repository: LookupRepository(
        const ResourceDescription(
          id: 'Team',
          name: 'Team',
          icon: 0xe7ef,
          fields: [
            ResourceField(id: 'id', name: 'Id', type: ResourceFieldType.string),
            ResourceField(
              id: 'name',
              name: 'Name',
              type: ResourceFieldType.string,
            ),
          ],
          relations: [],
          idField: 'id',
          displayFields: ['name'],
          readOnly: false,
          revisable: false,
          actions: [],
        ),
        [
          {'id': 'core', 'name': 'Core Team'},
        ],
      ),
    );

    expect(_title(tester), 'Core Team');
    expect(_isValueHidden(tester), isTrue);
  });
}
