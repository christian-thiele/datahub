import 'dart:convert';
import 'dart:typed_data';

import 'json_syntax.dart';

/// The kind of value a JSON editor has to hold at its root.
enum JsonRootType {
  object,
  array;

  bool accepts(dynamic value) => switch (this) {
    JsonRootType.object => value is Map,
    JsonRootType.array => value is List,
  };
}

/// Text of a JSON editor that is not valid JSON.
///
/// JSON editors hand it on as their value instead of the last valid value, so
/// that a form refuses to save text the user has not finished, instead of
/// silently saving something else.
class InvalidJson {
  final String text;

  /// The first part of [text] that is not valid JSON, if it could be found.
  final JsonSyntaxError? error;

  const InvalidJson(this.text, [this.error]);

  @override
  bool operator ==(Object other) => other is InvalidJson && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'InvalidJson($text)';
}

const _encoder = JsonEncoder.withIndent('  ');

/// Parses the text of a JSON editor.
///
/// Returns `null` for blank text, the decoded value for valid JSON and an
/// [InvalidJson] otherwise.
dynamic parseJsonText(String text) {
  if (text.trim().isEmpty) {
    return null;
  }

  try {
    return jsonDecode(text);
  } on FormatException catch (e) {
    // The offset of the exception is not available on the web, where the
    // browser parses JSON, so the error is located separately.
    final error =
        findJsonSyntaxError(text) ??
        switch (e.offset) {
          final offset? => JsonSyntaxError(offset, offset),
          null => null,
        };
    return InvalidJson(text, error);
  }
}

/// The text a JSON editor shows for [value].
String formatJson(dynamic value) => switch (value) {
  null => '',
  InvalidJson(:final text) => text,
  _ => _encoder.convert(value),
};

/// The first [InvalidJson] in [value], which may also be nested in maps and
/// lists, where JSON editors are part of an object or list field.
InvalidJson? findInvalidJson(dynamic value) => switch (value) {
  final InvalidJson invalid => invalid,
  // Binary data like the bytes of a file, too long to search in vain.
  TypedData() => null,
  final Map map => map.values.map(findInvalidJson).nonNulls.firstOrNull,
  final List list => list.map(findInvalidJson).nonNulls.firstOrNull,
  _ => null,
};
