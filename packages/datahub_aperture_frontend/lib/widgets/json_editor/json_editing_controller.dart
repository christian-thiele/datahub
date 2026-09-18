import 'package:flutter/material.dart';

import 'json_editor_style.dart';
import 'model/json_syntax.dart';
import 'model/json_value.dart';

/// A [TextEditingController] for JSON text, which highlights the syntax and
/// marks the first syntax error.
class JsonEditingController extends TextEditingController {
  JsonEditingController({super.text});

  String? _parsedText;
  dynamic _json;
  List<JsonToken> _tokens = const [];

  /// The value of [text], as returned by [parseJsonText].
  dynamic get json {
    _parse();
    return _json;
  }

  void _parse() {
    if (_parsedText == text) {
      return;
    }

    _parsedText = text;
    _json = parseJsonText(text);
    _tokens = tokenizeJson(text);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Input methods underline the text they compose, which the default
    // implementation takes care of.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    _parse();
    final editorStyle = JsonEditorStyle.of(context);
    final tokenStyles = {
      for (final type in JsonTokenType.values)
        type: editorStyle.tokenStyle(type),
    };
    final error = switch (_json) {
      InvalidJson(:final error?) => error,
      _ => null,
    };

    final spans = <TextSpan>[];
    void addSpan(int start, int end, TextStyle? tokenStyle) {
      // Split where the error starts and ends, to mark only the error.
      final bounds = [
        start,
        if (error != null) ...[
          error.start.clamp(start, end),
          error.end.clamp(start, end),
        ],
        end,
      ];
      for (var i = 1; i < bounds.length; i++) {
        final (from, to) = (bounds[i - 1], bounds[i]);
        if (from == to) {
          continue;
        }

        final isError = error != null && from >= error.start && to <= error.end;
        spans.add(
          TextSpan(
            text: text.substring(from, to),
            style: isError
                ? (tokenStyle ?? const TextStyle()).merge(
                    editorStyle.errorStyle,
                  )
                : tokenStyle,
          ),
        );
      }
    }

    var position = 0;
    for (final token in _tokens) {
      addSpan(position, token.start, null);
      addSpan(token.start, token.end, tokenStyles[token.type]);
      position = token.end;
    }
    addSpan(position, text.length, null);

    return TextSpan(style: style, children: spans);
  }
}
