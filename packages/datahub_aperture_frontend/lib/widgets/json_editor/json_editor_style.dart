import 'package:flutter/material.dart';

import 'model/json_syntax.dart';

/// Colours of the JSON syntax highlighting.
@immutable
class JsonEditorStyle {
  final Color key;
  final Color string;
  final Color number;
  final Color literal;
  final Color error;

  const JsonEditorStyle({
    required this.key,
    required this.string,
    required this.number,
    required this.literal,
    required this.error,
  });

  /// Token colours are fixed (IntelliJ Light), as the colour scheme is seeded
  /// from a configurable brand colour and its colours are neither guaranteed
  /// to differ from each other nor from the error colour.
  factory JsonEditorStyle.of(BuildContext context) => JsonEditorStyle(
    key: const Color(0xff871094),
    string: const Color(0xff067d17),
    number: const Color(0xff1750eb),
    literal: const Color(0xff0033b3),
    error: Theme.of(context).colorScheme.error,
  );

  TextStyle? tokenStyle(JsonTokenType type) => switch (type) {
    JsonTokenType.key => TextStyle(color: key),
    JsonTokenType.string => TextStyle(color: string),
    JsonTokenType.number => TextStyle(color: number),
    JsonTokenType.literal => TextStyle(color: literal),
    JsonTokenType.invalid => TextStyle(color: error),
    JsonTokenType.punctuation => null,
  };

  /// Marks the first syntax error.
  TextStyle get errorStyle => TextStyle(
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.wavy,
    decorationColor: error,
  );
}
