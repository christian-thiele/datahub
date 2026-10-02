import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../abstract/redis_reply.dart';

const _cr = 13;
const _lf = 10;
const _plus = 43;
const _minus = 45;
const _colon = 58;
const _dollar = 36;
const _asterisk = 42;

/// The received data violates the RESP2 protocol.
///
/// The stream cannot be resynchronized after a protocol error, so the
/// connection has to be closed.
class RespProtocolException implements Exception {
  final String message;

  const RespProtocolException(this.message);

  @override
  String toString() => 'RespProtocolException: $message';
}

/// Incremental parser for RESP2 replies.
///
/// Received chunks are passed to [add] and complete replies are taken out
/// with [next]. Replies may be split across chunks at any byte, and a single
/// chunk may contain any number of replies.
///
/// Parsing state is kept between chunks: elements of an array that were
/// already parsed are not parsed again when the rest of the array arrives
/// later, so large replies are processed in linear time. Bulk strings are
/// copied out of the receive buffer, so a reply never keeps a socket chunk
/// alive.
class RespParser {
  /// Upper bound for bulk string lengths, Redis' own `proto-max-bulk-len`
  /// default. Larger lengths can only result from a corrupt stream.
  static const maxBulkLength = 512 * 1024 * 1024;

  /// Upper bound for the length of a line (simple strings, errors, integers
  /// and headers). Exceeding it indicates a corrupt stream.
  static const maxLineLength = 1024 * 1024;

  static final _empty = Uint8List(0);

  Uint8List _buffer = _empty;
  int _start = 0;
  int _end = 0;

  /// Whether [_buffer] was allocated by the parser (and may be written to)
  /// or is a chunk adopted without copying.
  bool _owned = false;

  /// Minimum buffer size required to complete the current bulk string, so
  /// that large bulk strings are not grown chunk by chunk.
  int _capacityHint = 0;

  final _stack = <_ArrayFrame>[];

  /// Number of received bytes that were not consumed by [next] yet.
  int get bufferedLength => _end - _start;

  /// Whether a reply was started but not completed yet.
  bool get hasPartialReply => _stack.isNotEmpty || _end > _start;

  /// Appends a received [chunk] to the parse buffer.
  void add(Uint8List chunk) {
    if (chunk.isEmpty) {
      return;
    }

    final buffered = _end - _start;
    if (buffered == 0) {
      // nothing pending, adopt the chunk without copying
      _buffer = chunk;
      _start = 0;
      _end = chunk.length;
      _owned = false;
      return;
    }

    if (_owned && _end + chunk.length <= _buffer.length) {
      _buffer.setRange(_end, _end + chunk.length, chunk);
      _end += chunk.length;
      return;
    }

    final required = buffered + chunk.length;
    final Uint8List target;
    if (_owned && required <= _buffer.length) {
      // enough space when moving pending data to the front
      target = _buffer;
    } else {
      target = Uint8List(max(required, max(_capacityHint, buffered * 2)));
    }

    target.setRange(0, buffered, _buffer, _start);
    target.setRange(buffered, required, chunk);
    _buffer = target;
    _start = 0;
    _end = required;
    _owned = true;
  }

  /// Returns the next complete reply, or null if more data is required.
  ///
  /// Throws a [RespProtocolException] if the data is not valid RESP2.
  RedisReply? next() {
    while (true) {
      final element = _readElement();
      if (element == null) {
        return null;
      }

      RedisReply value;
      if (element is _ArrayFrame) {
        _stack.add(element);
        continue;
      } else {
        value = element as RedisReply;
      }

      while (true) {
        if (_stack.isEmpty) {
          _releaseConsumed();
          return value;
        }

        final frame = _stack.last;
        frame.items.add(value);
        if (frame.items.length < frame.length) {
          break;
        }

        _stack.removeLast();
        value = RedisArray(frame.items);
      }
    }
  }

  /// Reads a single element at [_start].
  ///
  /// Returns a [RedisReply] for complete elements, an [_ArrayFrame] for the
  /// header of a non-empty array or null if the element is incomplete. Only
  /// advances [_start] when an element was read completely.
  Object? _readElement() {
    if (_start >= _end) {
      return null;
    }

    final lineEnd = _findLineEnd(_start + 1);
    if (lineEnd == -1) {
      return null;
    }

    final type = _buffer[_start];
    final contentStart = lineEnd + 2;
    switch (type) {
      case _plus:
        final value = _decodeLine(_start + 1, lineEnd);
        _start = contentStart;
        return RedisSimpleString(value);

      case _minus:
        final value = _decodeLine(_start + 1, lineEnd);
        _start = contentStart;
        return RedisErrorReply(value);

      case _colon:
        final value = _parseInteger(_start + 1, lineEnd);
        _start = contentStart;
        return RedisInteger(value);

      case _dollar:
        final length = _parseInteger(_start + 1, lineEnd);
        if (length == -1) {
          _start = contentStart;
          return const RedisNull();
        }
        if (length < 0 || length > maxBulkLength) {
          throw RespProtocolException('Invalid bulk string length $length.');
        }

        final contentEnd = contentStart + length;
        if (contentEnd + 2 > _end) {
          _capacityHint = contentEnd + 2 - _start;
          return null;
        }
        if (_buffer[contentEnd] != _cr || _buffer[contentEnd + 1] != _lf) {
          throw const RespProtocolException(
            'Bulk string is not terminated by CRLF.',
          );
        }

        final bytes = _buffer.sublist(contentStart, contentEnd);
        _start = contentEnd + 2;
        _capacityHint = 0;
        return RedisBulkString(bytes);

      case _asterisk:
        final length = _parseInteger(_start + 1, lineEnd);
        _start = contentStart;
        if (length == -1) {
          return const RedisNull();
        }
        if (length < 0) {
          throw RespProtocolException('Invalid array length $length.');
        }
        if (length == 0) {
          return RedisArray(<RedisReply>[]);
        }
        return _ArrayFrame(length);

      default:
        throw RespProtocolException(
          'Unexpected reply type 0x${type.toRadixString(16).padLeft(2, '0')}'
          ' (only RESP2 is supported).',
        );
    }
  }

  /// Returns the index of the CR of the next CRLF at or after [from], or -1
  /// if the line is not complete yet.
  int _findLineEnd(int from) {
    for (var i = from; i < _end; i++) {
      if (_buffer[i] == _cr) {
        if (i + 1 >= _end) {
          return -1;
        }
        if (_buffer[i + 1] != _lf) {
          throw const RespProtocolException('CR is not followed by LF.');
        }
        return i;
      }
    }

    if (_end - _start > maxLineLength) {
      throw const RespProtocolException('Line exceeds maximum length.');
    }
    return -1;
  }

  String _decodeLine(int from, int to) => utf8.decode(
    Uint8List.sublistView(_buffer, from, to),
    allowMalformed: true,
  );

  int _parseInteger(int from, int to) {
    var i = from;
    var negative = false;
    if (i < to && _buffer[i] == _minus) {
      negative = true;
      i++;
    }
    if (i == to || to - i > 19) {
      throw RespProtocolException(
        'Invalid integer "${_decodeLine(from, to)}".',
      );
    }

    var value = 0;
    for (; i < to; i++) {
      final digit = _buffer[i] - 48;
      if (digit < 0 || digit > 9) {
        throw RespProtocolException(
          'Invalid integer "${_decodeLine(from, to)}".',
        );
      }
      value = value * 10 + digit;
    }
    return negative ? -value : value;
  }

  /// Drops the buffer once everything is consumed, so a large reply does not
  /// keep its buffer alive.
  void _releaseConsumed() {
    if (_start == _end) {
      _buffer = _empty;
      _start = 0;
      _end = 0;
      _owned = false;
    }
  }
}

class _ArrayFrame {
  final int length;
  final items = <RedisReply>[];

  _ArrayFrame(this.length);
}
