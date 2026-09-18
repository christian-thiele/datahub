import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'json_editing_controller.dart';
import 'json_indent_formatter.dart';
import 'model/json_value.dart';

/// An editor for JSON text.
///
/// The text is highlighted and checked while it is typed. [onChanged] gets the
/// decoded value, `null` for blank text and an [InvalidJson] while the text is
/// not valid JSON, so that a form can tell unfinished text from a value.
///
/// The editor is read-only when [onChanged] is `null`. Its text can still be
/// selected and copied then.
class JsonEditor extends StatefulWidget {
  final dynamic value;

  /// The kind of value the editor has to hold, any JSON value if `null`.
  final JsonRootType? root;
  final InputDecoration decoration;
  final ValueChanged<dynamic>? onChanged;

  const JsonEditor({
    super.key,
    this.value,
    this.root,
    this.decoration = const InputDecoration(),
    this.onChanged,
  });

  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  static const _formatShortcut = SingleActivator(
    LogicalKeyboardKey.keyF,
    shift: true,
    alt: true,
  );

  late final JsonEditingController _controller;

  /// The value the text was last set from or handed to [JsonEditor.onChanged],
  /// to tell an echo of our own change apart from a value replaced from the
  /// outside.
  dynamic _emitted;

  /// The text of the last change, as the controller also notifies about
  /// selection changes.
  late String _text;

  @override
  void initState() {
    super.initState();
    _emitted = widget.value;
    _text = formatJson(widget.value);
    _controller = JsonEditingController(text: _text)
      ..addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant JsonEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!fieldValueEquals(widget.value, _emitted)) {
      _emitted = widget.value;
      _controller.text = _text = formatJson(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.text == _text) {
      return;
    }

    // The error and the format button depend on the text.
    setState(() => _text = _controller.text);

    final value = _controller.json;
    if (!fieldValueEquals(value, _emitted)) {
      _emitted = value;
      widget.onChanged?.call(value);
    }
  }

  void _format() {
    final value = _controller.json;
    if (widget.onChanged == null || value == null || value is InvalidJson) {
      return;
    }

    final text = formatJson(value);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: _mapOffset(
          _controller.text,
          text,
          _controller.selection.baseOffset,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.onChanged == null;
    final value = _controller.json;
    final canFormat =
        !readOnly &&
        value != null &&
        value is! InvalidJson &&
        formatJson(value) != _controller.text;

    final field = TextField(
      controller: _controller,
      readOnly: readOnly,
      minLines: 3,
      maxLines: 20,
      autocorrect: false,
      enableSuggestions: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      inputFormatters: const [JsonIndentFormatter()],
      style: GoogleFonts.jetBrainsMono(
        textStyle: Theme.of(context).textTheme.bodyLarge,
      ),
      decoration: widget.decoration.copyWith(
        alignLabelWithHint: true,
        hintText: switch (widget.root) {
          JsonRootType.object => '{}',
          JsonRootType.array => '[]',
          null => null,
        },
        errorText:
            describeJsonError(S.of(context), value, root: widget.root) ??
            widget.decoration.errorText,
        counter: readOnly
            ? null
            : IconButton(
                tooltip: S.of(context).formatJson,
                onPressed: canFormat ? _format : null,
                icon: const Icon(Icons.format_align_left),
              ),
      ),
    );

    if (readOnly) {
      return field;
    }

    return CallbackShortcuts(
      bindings: {_formatShortcut: _format},
      child: field,
    );
  }
}

/// Moves [offset] in [from] to the same position in [to], where [to] is
/// [from] formatted differently.
///
/// Characters other than whitespace are counted, which keeps the cursor next
/// to the same character as long as formatting changed whitespace only.
int _mapOffset(String from, String to, int offset) {
  var characters = 0;
  for (var i = 0; i < offset && i < from.length; i++) {
    if (!_blanks.contains(from.codeUnitAt(i))) {
      characters++;
    }
  }

  var i = 0;
  for (; i < to.length && characters > 0; i++) {
    if (!_blanks.contains(to.codeUnitAt(i))) {
      characters--;
    }
  }
  return i;
}

const _blanks = {0x09, 0x0A, 0x0D, 0x20};
