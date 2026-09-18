import 'package:flutter/services.dart';

/// Indents a typed line break like the line it breaks, one level deeper after
/// an opening bracket.
///
/// A line break typed right between a pair of brackets also moves the closing
/// bracket to a line of its own.
class JsonIndentFormatter extends TextInputFormatter {
  static const indent = '  ';

  const JsonIndentFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!_isLineBreak(oldValue, newValue)) {
      return newValue;
    }

    final start = oldValue.selection.start;
    final before = newValue.text.substring(0, start);
    final line = before.substring(before.lastIndexOf('\n') + 1);
    final lineIndent = line.substring(0, line.length - line.trimLeft().length);

    // Whitespace after the cursor would indent the new line even further.
    final after = newValue.text.substring(start + 1).replaceFirst(_blanks, '');

    final opened = line.trimRight();
    final closing = opened.endsWith('{')
        ? '}'
        : opened.endsWith('[')
        ? ']'
        : null;
    final newIndent = closing != null ? lineIndent + indent : lineIndent;
    final closingLine = closing != null && after.startsWith(closing)
        ? '\n$lineIndent'
        : '';

    return TextEditingValue(
      text: '$before\n$newIndent$closingLine$after',
      selection: TextSelection.collapsed(offset: start + 1 + newIndent.length),
    );
  }

  /// Whether [newValue] is [oldValue] with its selection replaced by a single
  /// line break, as typed with the enter key.
  static bool _isLineBreak(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final selection = oldValue.selection;
    if (!selection.isValid ||
        !newValue.selection.isCollapsed ||
        newValue.selection.baseOffset != selection.start + 1) {
      return false;
    }

    final text = newValue.text;
    final removed = selection.end - selection.start;
    return text.length == oldValue.text.length - removed + 1 &&
        text.codeUnitAt(selection.start) == 0x0A &&
        text.startsWith(oldValue.text.substring(0, selection.start)) &&
        text.endsWith(oldValue.text.substring(selection.end));
  }

  static final _blanks = RegExp(r'^[ \t]+');
}
