import 'dart:convert';
import 'dart:typed_data';

const _cr = 13;
const _lf = 10;
const _dollar = 36;
const _asterisk = 42;

/// Encodes commands as RESP arrays of bulk strings.
abstract final class RespEncoder {
  /// Encodes [command] into a RESP request.
  ///
  /// Supported argument types are [String] (UTF-8), [int], [double] and
  /// [List<int>] (raw bytes, usually a [Uint8List]).
  ///
  /// Throws an [ArgumentError] for empty commands and unsupported argument
  /// types. Encoding is completed before anything is written to a
  /// connection, so an invalid command never leaves a partial request on the
  /// wire.
  static Uint8List encode(List<Object> command) {
    if (command.isEmpty) {
      throw ArgumentError.value(command, 'command', 'Command is empty.');
    }

    final arguments = [
      for (final argument in command) encodeArgument(argument),
    ];

    var length = _headerLength(command.length);
    for (final argument in arguments) {
      length += _headerLength(argument.length) + argument.length + 2;
    }

    final buffer = Uint8List(length);
    var offset = _writeHeader(buffer, 0, _asterisk, command.length);
    for (final argument in arguments) {
      offset = _writeHeader(buffer, offset, _dollar, argument.length);
      buffer.setRange(offset, offset + argument.length, argument);
      offset += argument.length;
      buffer[offset++] = _cr;
      buffer[offset++] = _lf;
    }

    return buffer;
  }

  /// Converts a single command argument to its bulk string bytes.
  static List<int> encodeArgument(Object argument) => switch (argument) {
    String() => utf8.encode(argument),
    int() => ascii.encode(argument.toString()),
    double() => ascii.encode(_formatDouble(argument)),
    List<int>() => argument,
    _ => throw ArgumentError.value(
      argument,
      'argument',
      'Unsupported Redis argument type ${argument.runtimeType}. '
          'Use String, int, double or List<int>.',
    ),
  };

  static String _formatDouble(double value) {
    if (value.isNaN) {
      throw ArgumentError.value(value, 'argument', 'NaN is not supported.');
    }
    if (value == double.infinity) {
      return '+inf';
    }
    if (value == double.negativeInfinity) {
      return '-inf';
    }
    return value.toString();
  }

  /// Length of a header like `$12\r\n`.
  static int _headerLength(int value) => value.toString().length + 3;

  static int _writeHeader(Uint8List buffer, int offset, int type, int value) {
    buffer[offset++] = type;
    final digits = value.toString();
    for (var i = 0; i < digits.length; i++) {
      buffer[offset++] = digits.codeUnitAt(i);
    }
    buffer[offset++] = _cr;
    buffer[offset++] = _lf;
    return offset;
  }
}
