/// Kinds of [JsonToken]s.
enum JsonTokenType {
  /// One of `{`, `}`, `[`, `]`, `:` and `,`.
  punctuation,

  /// A string followed by `:`, the name of an object member.
  key,
  string,
  number,

  /// `true`, `false` or `null`.
  literal,

  /// Anything else, like unquoted words.
  invalid,
}

/// A span of JSON text that is not valid JSON.
class JsonSyntaxError {
  final int start;
  final int end;

  const JsonSyntaxError(this.start, this.end);

  /// The 1-based line and column of [start] in [text].
  (int line, int column) positionIn(String text) {
    var line = 1;
    var lineStart = 0;
    for (var i = 0; i < start && i < text.length; i++) {
      if (text.codeUnitAt(i) == _lineFeed) {
        line++;
        lineStart = i + 1;
      }
    }
    return (line, start - lineStart + 1);
  }

  @override
  bool operator ==(Object other) =>
      other is JsonSyntaxError && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'JsonSyntaxError($start, $end)';
}

/// A lexical element of JSON text.
class JsonToken {
  final JsonTokenType type;
  final int start;
  final int end;

  /// The part of a malformed token that is wrong, like a bad escape sequence
  /// in a string.
  final JsonSyntaxError? error;

  const JsonToken(this.type, this.start, this.end, [this.error]);

  @override
  bool operator ==(Object other) =>
      other is JsonToken &&
      other.type == type &&
      other.start == start &&
      other.end == end &&
      other.error == error;

  @override
  int get hashCode => Object.hash(type, start, end, error);

  @override
  String toString() => 'JsonToken(${type.name}, $start, $end, $error)';
}

/// Splits [text] into tokens, skipping whitespace.
///
/// Any text can be tokenized, so that JSON can be highlighted while it is
/// typed. Strings end at the end of their line at the latest, so that a
/// missing quote does not turn the rest of the text into a string.
List<JsonToken> tokenizeJson(String text) {
  final tokens = <JsonToken>[];
  var i = 0;
  while (i < text.length) {
    final char = text.codeUnitAt(i);
    if (_isWhitespace(char)) {
      i++;
    } else if (_isPunctuation(char)) {
      if (char == _colon && tokens.lastOrNull?.type == JsonTokenType.string) {
        final string = tokens.removeLast();
        tokens.add(
          JsonToken(JsonTokenType.key, string.start, string.end, string.error),
        );
      }
      tokens.add(JsonToken(JsonTokenType.punctuation, i, i + 1));
      i++;
    } else if (char == _quote) {
      final string = _scanString(text, i);
      tokens.add(string);
      i = string.end;
    } else {
      var end = i + 1;
      while (end < text.length && !_isDelimiter(text.codeUnitAt(end))) {
        end++;
      }
      tokens.add(_scanWord(text, i, end));
      i = end;
    }
  }
  return tokens;
}

/// Finds the first part of [text] that is not valid JSON.
///
/// Returns `null` for valid JSON. Blank text is not valid JSON, its error is
/// at the end of the text.
JsonSyntaxError? findJsonSyntaxError(String text) {
  final open = <int>[];
  var expected = _Expected.value;

  for (final token in tokenizeJson(text)) {
    final char = token.type == JsonTokenType.punctuation
        ? text.codeUnitAt(token.start)
        : null;
    final unexpected = JsonSyntaxError(token.start, token.end);

    switch (expected) {
      case _Expected.value || _Expected.valueOrEnd:
        if (char == _closeBracket && expected == _Expected.valueOrEnd) {
          open.removeLast();
          expected = _afterValue(open);
        } else if (char == _openBrace || char == _openBracket) {
          open.add(char!);
          expected = char == _openBrace
              ? _Expected.keyOrEnd
              : _Expected.valueOrEnd;
        } else if (token.type
            case JsonTokenType.key ||
                JsonTokenType.string ||
                JsonTokenType.number ||
                JsonTokenType.literal) {
          if (token.error case final error?) {
            return error;
          }
          expected = _afterValue(open);
        } else {
          return unexpected;
        }
      case _Expected.key || _Expected.keyOrEnd:
        if (char == _closeBrace && expected == _Expected.keyOrEnd) {
          open.removeLast();
          expected = _afterValue(open);
        } else if (token.type case JsonTokenType.key || JsonTokenType.string) {
          if (token.error case final error?) {
            return error;
          }
          expected = _Expected.colon;
        } else {
          return unexpected;
        }
      case _Expected.colon:
        if (char != _colon) {
          return unexpected;
        }
        expected = _Expected.value;
      case _Expected.commaOrEnd:
        final isObject = open.last == _openBrace;
        if (char == _comma) {
          expected = isObject ? _Expected.key : _Expected.value;
        } else if (char == (isObject ? _closeBrace : _closeBracket)) {
          open.removeLast();
          expected = _afterValue(open);
        } else {
          return unexpected;
        }
      case _Expected.nothing:
        return unexpected;
    }
  }

  return expected == _Expected.nothing
      ? null
      : JsonSyntaxError(text.length, text.length);
}

/// What [findJsonSyntaxError] accepts next. "End" is the end of the innermost
/// object or array.
enum _Expected { value, valueOrEnd, key, keyOrEnd, colon, commaOrEnd, nothing }

_Expected _afterValue(List<int> open) =>
    open.isEmpty ? _Expected.nothing : _Expected.commaOrEnd;

JsonToken _scanString(String text, int start) {
  JsonSyntaxError? error;
  var i = start + 1;
  while (i < text.length) {
    final char = text.codeUnitAt(i);
    if (char == _quote) {
      return JsonToken(JsonTokenType.string, start, i + 1, error);
    } else if (char == _lineFeed || char == _carriageReturn) {
      break;
    } else if (char == _backslash) {
      final length = _escapeLength(text, i);
      if (length == null) {
        error ??= JsonSyntaxError(i, i + 1);
        i++;
      } else {
        i += length;
      }
    } else {
      if (char < 0x20) {
        error ??= JsonSyntaxError(i, i + 1);
      }
      i++;
    }
  }
  return JsonToken(
    JsonTokenType.string,
    start,
    i,
    error ?? JsonSyntaxError(start, i),
  );
}

/// The length of the escape sequence at [start], `null` if it is invalid.
int? _escapeLength(String text, int start) {
  if (start + 1 >= text.length) {
    return null;
  }

  return switch (text[start + 1]) {
    '"' || r'\' || '/' || 'b' || 'f' || 'n' || 'r' || 't' => 2,
    'u' when _unicodeEscape.matchAsPrefix(text, start) != null => 6,
    _ => null,
  };
}

JsonToken _scanWord(String text, int start, int end) {
  final word = text.substring(start, end);
  if (word == 'true' || word == 'false' || word == 'null') {
    return JsonToken(JsonTokenType.literal, start, end);
  }

  final first = text.codeUnitAt(start);
  if (first == _minus || (first >= _zero && first <= _nine)) {
    return JsonToken(
      JsonTokenType.number,
      start,
      end,
      _number.hasMatch(word) ? null : JsonSyntaxError(start, end),
    );
  }

  return JsonToken(
    JsonTokenType.invalid,
    start,
    end,
    JsonSyntaxError(start, end),
  );
}

final _number = RegExp(
  r'^-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?$',
);
final _unicodeEscape = RegExp(r'\\u[0-9a-fA-F]{4}');

const _tab = 0x09;
const _lineFeed = 0x0A;
const _carriageReturn = 0x0D;
const _space = 0x20;
const _quote = 0x22;
const _comma = 0x2C;
const _minus = 0x2D;
const _zero = 0x30;
const _nine = 0x39;
const _colon = 0x3A;
const _openBracket = 0x5B;
const _backslash = 0x5C;
const _closeBracket = 0x5D;
const _openBrace = 0x7B;
const _closeBrace = 0x7D;

bool _isWhitespace(int char) =>
    char == _space ||
    char == _lineFeed ||
    char == _carriageReturn ||
    char == _tab;

bool _isPunctuation(int char) =>
    char == _openBrace ||
    char == _closeBrace ||
    char == _openBracket ||
    char == _closeBracket ||
    char == _colon ||
    char == _comma;

bool _isDelimiter(int char) =>
    _isWhitespace(char) || _isPunctuation(char) || char == _quote;
