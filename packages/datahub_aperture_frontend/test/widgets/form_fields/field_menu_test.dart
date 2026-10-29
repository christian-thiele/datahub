import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/field_menu.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_field_form.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _id = ResourceField(
  id: 'id',
  name: 'Id',
  type: ResourceFieldType.int,
  readOnly: true,
);
const _note = ResourceField(
  id: 'note',
  name: 'Note',
  type: ResourceFieldType.string,
  nullable: true,
);
const _due = ResourceField(
  id: 'due',
  name: 'Due',
  type: ResourceFieldType.timestamp,
  nullable: true,
);
const _count = ResourceField(
  id: 'count',
  name: 'Count',
  type: ResourceFieldType.int,
);

final _data = ResourceData(
  id: '1',
  fieldData: {
    'id': 1,
    'note': 'hello',
    'due': DateTime.utc(2026, 10, 29, 14, 5),
    'count': 5,
  },
);

/// The calls of the form, by kind.
class _Calls {
  final changed = <(String, dynamic)>[];
  final reset = <String>[];
}

Future<_Calls> _pumpForm(
  WidgetTester tester, {
  Map<ResourceField, dynamic> changes = const {},
  Map<String, dynamic>? fieldData,
  bool readOnly = false,
  ThemeData? theme,
}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ResourceFieldForm(
            fields: const [_id, _note, _due, _count],
            data: fieldData != null
                ? ResourceData(id: '1', fieldData: fieldData)
                : _data,
            changes: changes,
            validations: const {},
            onFieldValueChanged: (field, value) =>
                calls.changed.add((field.id, value)),
            onFieldReset: (field) => calls.reset.add(field.id),
            onSavePressed: null,
            readOnly: readOnly,
          ),
        ),
      ),
    ),
  );
  return calls;
}

/// The menu of the field with [id].
Finder _menuOf(String id) => find.descendant(
  of: find.ancestor(
    of: find.byWidgetPredicate(
      (widget) => widget is ResourceFormField && widget.field.id == id,
    ),
    matching: find.byType(FieldMenu),
  ),
  matching: find.byIcon(Icons.more_vert),
);

Future<void> _openMenuOf(WidgetTester tester, String id) async {
  await tester.tap(_menuOf(id));
  await tester.pumpAndSettle();
}

MenuItemButton _item(WidgetTester tester, String label) =>
    tester.widget<MenuItemButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(MenuItemButton),
      ),
    );

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
    await initializeDateFormatting();
  });

  testWidgets('sets a field to null', (tester) async {
    final calls = await _pumpForm(tester);

    await _openMenuOf(tester, 'note');
    await tester.tap(find.text('Set to null'));
    await tester.pumpAndSettle();

    expect(calls.changed, [('note', null)]);
  });

  testWidgets('sets a timestamp to now', (tester) async {
    final calls = await _pumpForm(tester);

    await _openMenuOf(tester, 'due');
    expect(find.text('Set to null'), findsOneWidget);
    final before = DateTime.timestamp();
    await tester.tap(find.text('Set to now'));
    await tester.pumpAndSettle();

    final (id, value) = calls.changed.single;
    expect(id, 'due');
    expect(
      (value as DateTime).difference(before).inSeconds,
      inInclusiveRange(0, 5),
    );
  });

  testWidgets('resets a changed field', (tester) async {
    final calls = await _pumpForm(tester, changes: {_count: 7});

    await _openMenuOf(tester, 'count');
    expect(find.text('Set to null'), findsNothing, reason: 'not nullable');
    expect(find.text('Set to now'), findsNothing);
    await tester.tap(find.text('Reset to original value'));
    await tester.pumpAndSettle();

    expect(calls.reset, ['count']);
  });

  testWidgets('offers only what changes the value', (tester) async {
    await _pumpForm(
      tester,
      fieldData: {'id': 1, 'note': null, 'due': null, 'count': 5},
    );

    await _openMenuOf(tester, 'note');

    expect(_item(tester, 'Reset to original value').onPressed, isNull);
    expect(_item(tester, 'Set to null').onPressed, isNull);
  });

  testWidgets('has no menu for fields that can not be changed', (tester) async {
    await _pumpForm(tester);
    expect(_menuOf('id'), findsNothing);

    await _pumpForm(tester, readOnly: true);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('shows null apart from empty text', (tester) async {
    /// How visible the hint of the note is, `null` without a hint.
    double? nullHint() {
      final hint = find.descendant(
        of: find.byType(TextField).at(1),
        matching: find.text('null'),
      );
      if (hint.evaluate().isEmpty) {
        return null;
      }
      return tester
          .widget<AnimatedOpacity>(
            find.ancestor(of: hint, matching: find.byType(AnimatedOpacity)),
          )
          .opacity;
    }

    await _pumpForm(
      tester,
      fieldData: {'id': 1, 'note': null, 'due': null, 'count': 5},
    );
    await tester.pumpAndSettle();
    expect(nullHint(), 1, reason: 'also without focus');

    await _pumpForm(
      tester,
      fieldData: {'id': 1, 'note': '', 'due': null, 'count': 5},
    );
    await tester.pumpAndSettle();
    expect(nullHint(), isNull);
  });

  testWidgets('keeps the context menu of the text', (tester) async {
    await _pumpForm(tester);

    // On the word, not after it.
    await tester.longPressAt(
      tester.getTopLeft(find.text('hello')) + const Offset(8, 8),
    );
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Set to null'), findsNothing);
  });

  testWidgets('always shows the menu button on touch screens', (tester) async {
    await _pumpForm(tester, theme: ThemeData(platform: TargetPlatform.iOS));

    final opacity = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: _menuOf('note'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacity.opacity, 1);
  });

  testWidgets('shows the menu button on hover with a pointer', (tester) async {
    await _pumpForm(tester, theme: ThemeData(platform: TargetPlatform.macOS));
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: _menuOf('note'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(opacity(), 0);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('hello')));
    await tester.pumpAndSettle();

    expect(opacity(), 1);
  });

  testWidgets('hides the menu button again after an action', (tester) async {
    await _pumpForm(tester, theme: ThemeData(platform: TargetPlatform.macOS));
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: _menuOf('note'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('hello')));
    await tester.pumpAndSettle();

    await mouse.moveTo(tester.getCenter(_menuOf('note')));
    await mouse.down(tester.getCenter(_menuOf('note')));
    await mouse.up();
    await tester.pumpAndSettle();
    await mouse.moveTo(tester.getCenter(find.text('Set to null')));
    await tester.pumpAndSettle();
    await mouse.down(tester.getCenter(find.text('Set to null')));
    await mouse.up();
    await tester.pumpAndSettle();

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();

    expect(opacity(), 0);
  });

  testWidgets('shows the menu button while the field has focus', (
    tester,
  ) async {
    await _pumpForm(tester, theme: ThemeData(platform: TargetPlatform.macOS));
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: _menuOf('note'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;

    await tester.showKeyboard(find.text('hello'));
    await tester.pumpAndSettle();
    expect(opacity(), 1);

    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pumpAndSettle();
    expect(opacity(), 0);
  });
}
