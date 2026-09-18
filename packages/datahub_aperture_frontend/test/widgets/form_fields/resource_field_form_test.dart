import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/group_decoration.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_field_form.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _numbers = ResourceField(
  id: 'numbers',
  name: 'Numbers',
  type: ResourceFieldType.list,
  objectDescription: [
    ResourceField(id: 'element', name: '', type: ResourceFieldType.int),
  ],
);
const _period = ResourceField(
  id: 'period',
  name: 'Period',
  type: ResourceFieldType.object,
  objectDescription: [
    ResourceField(id: 'label', name: 'Label', type: ResourceFieldType.string),
  ],
);

Future<void> _pumpForm(
  WidgetTester tester,
  Map<String, String> validations,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ResourceFieldForm(
            fields: const [_numbers, _period],
            data: ResourceData(
              id: '1',
              fieldData: {
                'numbers': [1, null],
                'period': {'label': 'Q1'},
              },
            ),
            changes: const {},
            validations: validations,
            onFieldValueChanged: (_, _) {},
            onSavePressed: null,
          ),
        ),
      ),
    ),
  );
  // Error texts fade in.
  await tester.pump(const Duration(milliseconds: 500));
}

/// The form field of the value at [path].
Finder _fieldAt(String path) => find.byWidgetPredicate(
  (widget) => widget is ResourceFormField && widget.path == path,
);

Finder _textAt(String path, String text) =>
    find.descendant(of: _fieldAt(path), matching: find.text(text));

GroupDecoration _groupOf(WidgetTester tester, String path) =>
    tester.widget<GroupDecoration>(
      find
          .descendant(
            of: _fieldAt(path),
            matching: find.byType(GroupDecoration),
          )
          .first,
    );

void main() {
  testWidgets('shows the errors of list elements at the elements', (
    tester,
  ) async {
    await _pumpForm(tester, {'numbers[1]': 'Expected int.'});

    expect(_textAt('numbers[1]', 'Expected int.'), findsOneWidget);
    expect(_textAt('numbers[0]', 'Expected int.'), findsNothing);
    expect(_groupOf(tester, 'numbers').hasNestedErrors, isTrue);
  });

  testWidgets('shows the errors of object members at the members', (
    tester,
  ) async {
    await _pumpForm(tester, {'period.label': 'Too short.'});

    expect(_textAt('period.label', 'Too short.'), findsOneWidget);
    expect(_groupOf(tester, 'period').hasNestedErrors, isTrue);
    expect(_groupOf(tester, 'numbers').hasNestedErrors, isFalse);
  });

  testWidgets('shows the errors of lists and objects themselves', (
    tester,
  ) async {
    await _pumpForm(tester, {'numbers': 'Value is required.'});

    expect(_textAt('numbers', 'Value is required.'), findsOneWidget);
    expect(_groupOf(tester, 'numbers').hasNestedErrors, isFalse);
  });
}
