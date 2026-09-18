import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/json_editing_controller.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/json_editor.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/json_editor_style.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/model/json_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _formatTooltip = 'Format JSON (Shift+Alt+F)';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: const [S.delegate],
  supportedLocales: S.delegate.supportedLocales,
  home: Scaffold(body: child),
);

/// Keeps the value the editor emits, like a form does.
class _Form extends StatefulWidget {
  final dynamic initialValue;
  final JsonRootType? root;
  final List<dynamic> emitted;

  const _Form({this.initialValue, this.root, required this.emitted});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late dynamic value = widget.initialValue;

  @override
  Widget build(BuildContext context) => JsonEditor(
    value: value,
    root: widget.root,
    decoration: const InputDecoration(labelText: 'Settings'),
    onChanged: (v) => setState(() {
      widget.emitted.add(v);
      value = v;
    }),
  );
}

extension on WidgetTester {
  TextEditingController get controller =>
      widget<TextField>(find.byType(TextField)).controller!;

  Future<void> pumpForm(
    List<dynamic> emitted, {
    dynamic value,
    JsonRootType? root,
  }) async {
    await pumpWidget(
      _app(_Form(initialValue: value, root: root, emitted: emitted)),
    );
    await pump();
  }
}

void main() {
  testWidgets('shows the value formatted', (tester) async {
    await tester.pumpForm(
      [],
      value: {
        'a': [1],
      },
    );

    expect(tester.controller.text, '{\n  "a": [\n    1\n  ]\n}');
  });

  testWidgets('emits decoded JSON', (tester) async {
    final emitted = [];
    await tester.pumpForm(emitted, root: JsonRootType.object);

    await tester.enterText(find.byType(TextField), '{"a": [1, true]}');
    await tester.pump();

    expect(emitted, [
      {
        'a': [1, true],
      },
    ]);
    expect(find.textContaining('Invalid JSON'), findsNothing);
  });

  testWidgets('emits invalid JSON and shows where it is invalid', (
    tester,
  ) async {
    final emitted = [];
    await tester.pumpForm(emitted, value: {'a': 1});

    await tester.enterText(find.byType(TextField), '{\n  "a": }');
    await tester.pump();

    expect(emitted, [const InvalidJson('{\n  "a": }')]);
    expect(find.text('Invalid JSON (line 2, column 8).'), findsOneWidget);
  });

  testWidgets('shows a value of the wrong kind as error', (tester) async {
    final emitted = [];
    await tester.pumpForm(emitted, root: JsonRootType.object);

    await tester.enterText(find.byType(TextField), '[1]');
    await tester.pump();

    expect(emitted, [
      [1],
    ]);
    expect(find.text('Value must be a JSON object.'), findsOneWidget);
  });

  testWidgets('emits null for blank text', (tester) async {
    final emitted = [];
    await tester.pumpForm(emitted, value: {'a': 1});

    await tester.enterText(find.byType(TextField), '  ');
    await tester.pump();

    expect(emitted, [null]);
  });

  testWidgets('does not emit when only whitespace changes', (tester) async {
    final emitted = [];
    await tester.pumpForm(emitted, value: {'a': 1});

    await tester.enterText(find.byType(TextField), '{"a":1}');
    await tester.pump();

    expect(emitted, isEmpty);
    expect(tester.controller.text, '{"a":1}');
  });

  testWidgets('keeps the text when its own value comes back', (tester) async {
    final emitted = [];
    await tester.pumpForm(emitted, value: {'a': 1});

    await tester.enterText(find.byType(TextField), '{"a":2}');
    await tester.pump();

    expect(emitted, [
      {'a': 2},
    ]);
    expect(tester.controller.text, '{"a":2}');
  });

  testWidgets('shows a value replaced from the outside', (tester) async {
    await tester.pumpWidget(
      _app(JsonEditor(value: const {'a': 1}, onChanged: (_) {})),
    );
    await tester.enterText(find.byType(TextField), '{"a":1}');

    await tester.pumpWidget(
      _app(JsonEditor(value: const {'a': 2}, onChanged: (_) {})),
    );

    expect(tester.controller.text, '{\n  "a": 2\n}');
  });

  testWidgets('formats the text with the format button', (tester) async {
    final emitted = [];
    await tester.pumpForm(emitted);

    await tester.enterText(find.byType(TextField), '{"a":[1]}');
    await tester.pump();
    await tester.tap(find.byTooltip(_formatTooltip));
    await tester.pump();

    expect(tester.controller.text, '{\n  "a": [\n    1\n  ]\n}');
    expect(emitted, hasLength(1), reason: 'formatting keeps the value');
  });

  testWidgets('can only format valid, unformatted JSON', (tester) async {
    await tester.pumpForm([]);

    IconButton button() => tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip(_formatTooltip),
        matching: find.byType(IconButton),
      ),
    );

    await tester.enterText(find.byType(TextField), '{"a":');
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '{\n  "a": 1\n}');
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '{"a": 1}');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('formats the text with shift + alt + F', (tester) async {
    await tester.pumpForm([]);

    await tester.enterText(find.byType(TextField), '[1,2]');
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(tester.controller.text, '[\n  1,\n  2\n]');
  });

  testWidgets('keeps the cursor next to the same character when formatting', (
    tester,
  ) async {
    await tester.pumpForm([]);

    await tester.enterText(find.byType(TextField), '{"a":[1,2]}');
    tester.controller.selection = const TextSelection.collapsed(offset: 8);
    await tester.pump();
    await tester.tap(find.byTooltip(_formatTooltip));
    await tester.pump();

    final text = tester.controller.text;
    final offset = tester.controller.selection.baseOffset;
    expect(text.substring(offset - 2, offset), '1,');
  });

  testWidgets('indents new lines', (tester) async {
    await tester.pumpForm([]);

    await tester.enterText(find.byType(TextField), '{}');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '{}',
        selection: TextSelection.collapsed(offset: 1),
      ),
    );
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '{\n}',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.pump();

    expect(tester.controller.text, '{\n  \n}');
    expect(tester.controller.selection.baseOffset, 4);
  });

  testWidgets('is read-only without onChanged', (tester) async {
    await tester.pumpWidget(_app(JsonEditor(value: const {'a': 1})));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.readOnly, isTrue);
    expect(field.enabled, isNot(false), reason: 'the text can be selected');
    expect(find.byTooltip(_formatTooltip), findsNothing);
  });

  testWidgets('highlights the syntax and marks the error', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final style = JsonEditorStyle.of(context);
    final controller = JsonEditingController(text: '{"a": [1, true, "b"], x}');
    final span = controller.buildTextSpan(
      context: context,
      withComposing: false,
    );
    controller.dispose();

    final spans = {
      for (final child in span.children!.cast<TextSpan>())
        child.text!: child.style,
    };
    expect(spans['"a"']?.color, style.key);
    expect(spans['1']?.color, style.number);
    expect(spans['true']?.color, style.literal);
    expect(spans['"b"']?.color, style.string);
    expect(spans['x']?.decorationStyle, TextDecorationStyle.wavy);
    expect(spans['}']?.decoration, isNull);
    expect(span.toPlainText(), '{"a": [1, true, "b"], x}');
  });
}
