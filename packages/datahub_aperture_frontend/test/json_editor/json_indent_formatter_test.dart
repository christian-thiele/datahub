import 'package:datahub_aperture_frontend/widgets/json_editor/json_indent_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parses `|` as the cursor, or two of them as the selection.
TextEditingValue _value(String text) {
  final start = text.indexOf('|');
  final end = text.lastIndexOf('|');
  return TextEditingValue(
    text: text.replaceAll('|', ''),
    selection: TextSelection(
      baseOffset: start,
      extentOffset: start == end ? start : end - 1,
    ),
  );
}

/// Types [input] at the cursor of [text], and returns the formatted result
/// with its cursor as `|`.
String _type(String text, String input) {
  final oldValue = _value(text);
  final selection = oldValue.selection;
  final newValue = TextEditingValue(
    text:
        '${selection.textBefore(oldValue.text)}$input'
        '${selection.textAfter(oldValue.text)}',
    selection: TextSelection.collapsed(offset: selection.start + input.length),
  );

  final result = const JsonIndentFormatter().formatEditUpdate(
    oldValue,
    newValue,
  );
  expect(result.selection.isCollapsed, isTrue);
  return '${result.selection.textBefore(result.text)}|'
      '${result.selection.textAfter(result.text)}';
}

void main() {
  test('keeps the indentation of the line', () {
    expect(_type('{\n  "a": 1,|\n}', '\n'), '{\n  "a": 1,\n  |\n}');
  });

  test('indents after an opening bracket', () {
    expect(_type('{\n  "a": [|', '\n'), '{\n  "a": [\n    |');
    expect(_type('{ |', '\n'), '{ \n  |');
  });

  test('moves the closing bracket to a line of its own', () {
    expect(_type('{|}', '\n'), '{\n  |\n}');
    expect(_type('  "a": [|]', '\n'), '  "a": [\n    |\n  ]');
  });

  test('drops blanks after the cursor', () {
    expect(_type('{|   "a": 1}', '\n'), '{\n  |"a": 1}');
  });

  test('replaces the selection', () {
    expect(_type('{|"a": 1|}', '\n'), '{\n  |\n}');
  });

  test('leaves other input alone', () {
    expect(_type('{|}', 'a'), '{a|}');
    expect(_type('{|}', '\n"a": 1\n'), '{\n"a": 1\n|}');
  });
}
