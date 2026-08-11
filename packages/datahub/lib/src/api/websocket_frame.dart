import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

enum WebsocketOpcode {
  continuation(0x0),
  text(0x1),
  binary(0x2),
  close(0x8),
  ping(0x9),
  pong(0xA);

  final int value;
  const WebsocketOpcode(this.value);

  /// Whether this is a control frame opcode (close, ping, pong).
  bool get isControl => (value & 0x8) != 0;

  static WebsocketOpcode fromValue(int value) {
    return maybeFromValue(value) ??
        (throw WebsocketProtocolException('Unknown opcode: $value.'));
  }

  static WebsocketOpcode? maybeFromValue(int value) {
    for (final opcode in WebsocketOpcode.values) {
      if (opcode.value == value) {
        return opcode;
      }
    }
    return null;
  }
}

/// An incoming frame violated RFC 6455.
///
/// [closeCode] is the websocket close code that should be sent to the
/// peer when failing the connection (usually 1002 protocol error or
/// 1009 message too big).
class WebsocketProtocolException implements Exception {
  final String message;
  final int closeCode;

  WebsocketProtocolException(this.message, [this.closeCode = 1002]);

  @override
  String toString() => 'WebsocketProtocolException: $message';
}

class WebsocketFrame {
  final bool fin;
  final WebsocketOpcode opcode;
  final Uint8List payload;

  String get text => utf8.decode(payload);

  /// Close code carried by a close frame, if any.
  int? get closeCode => opcode == WebsocketOpcode.close && payload.length >= 2
      ? ByteData.sublistView(payload).getUint16(0)
      : null;

  /// Close reason carried by a close frame, if any.
  String? get closeReason =>
      opcode == WebsocketOpcode.close && payload.length > 2
      ? utf8.decode(payload.sublist(2), allowMalformed: true)
      : null;

  WebsocketFrame(this.opcode, this.payload, {this.fin = true});

  WebsocketFrame.text(String text, {bool fin = true})
    : this(WebsocketOpcode.text, utf8.encode(text), fin: fin);

  WebsocketFrame.binary(Uint8List data, {bool fin = true})
    : this(WebsocketOpcode.binary, data, fin: fin);

  WebsocketFrame.ping([Uint8List? data])
    : this(WebsocketOpcode.ping, data ?? Uint8List(0));

  WebsocketFrame.pong([Uint8List? data])
    : this(WebsocketOpcode.pong, data ?? Uint8List(0));

  WebsocketFrame.close([int? code, String? reason])
    : this(WebsocketOpcode.close, _encodeClosePayload(code, reason));

  static Uint8List _encodeClosePayload(int? code, String? reason) {
    if (code == null) return Uint8List(0);
    // RFC 6455 section 7.4: 1004-1006 and 1015 must not be sent on the wire,
    // codes below 1000 and above 4999 are invalid.
    if (code < 1000 ||
        code > 4999 ||
        (code >= 1004 && code <= 1006) ||
        code == 1015) {
      throw ArgumentError.value(code, 'code', 'Invalid websocket close code');
    }
    final reasonBytes = reason != null ? utf8.encode(reason) : Uint8List(0);
    if (reasonBytes.length > 123) {
      throw ArgumentError.value(
        reason,
        'reason',
        'Close reason must not exceed 123 bytes of UTF-8',
      );
    }
    final payload = Uint8List(2 + reasonBytes.length);
    payload.buffer.asByteData().setUint16(0, code);
    payload.setAll(2, reasonBytes);
    return payload;
  }
}

class WebsocketFrameDecoder
    extends StreamTransformerBase<Uint8List, WebsocketFrame> {
  /// 16 MiB
  static const defaultMaxFrameSize = 0x1000000;

  /// Maximum accepted payload size of a single frame. Larger frames fail
  /// the connection with close code 1009 (message too big).
  final int maxFrameSize;

  /// Whether frames are required to be masked (RFC 6455 section 5.1
  /// requires this for client-to-server frames).
  final bool requireMask;

  const WebsocketFrameDecoder({
    this.maxFrameSize = defaultMaxFrameSize,
    this.requireMask = true,
  });

  @override
  Stream<WebsocketFrame> bind(Stream<Uint8List> stream) {
    final controller = StreamController<WebsocketFrame>();
    final buffer = BytesBuilder(copy: false);
    StreamSubscription<Uint8List>? subscription;
    // bytes required in [buffer] before parsing is attempted again
    var needed = 2;
    var failed = false;

    void fail(WebsocketProtocolException exception) {
      failed = true;
      controller.addError(exception);
      subscription?.cancel();
      controller.close();
    }

    void onData(Uint8List data) {
      if (failed) return;
      buffer.add(data);
      if (buffer.length < needed) return;

      final bytes = buffer.takeBytes();
      var offset = 0;

      while (!failed) {
        final remaining = bytes.length - offset;
        if (remaining < 2) {
          needed = 2;
          break;
        }

        final b1 = bytes[offset];
        final b2 = bytes[offset + 1];

        if (b1 & 0x70 != 0) {
          fail(
            WebsocketProtocolException(
              'Unexpected RSV bits (no extension negotiated).',
            ),
          );
          break;
        }

        final fin = (b1 & 0x80) != 0;
        final opcode = WebsocketOpcode.maybeFromValue(b1 & 0x0F);
        final masked = (b2 & 0x80) != 0;
        var payloadLength = b2 & 0x7F;

        var headerSize = 2;
        if (payloadLength == 126) {
          headerSize += 2;
        } else if (payloadLength == 127) {
          headerSize += 8;
        }
        if (masked) {
          headerSize += 4;
        }

        if (remaining < headerSize) {
          needed = headerSize;
          break;
        }

        if (payloadLength == 126) {
          payloadLength = ByteData.sublistView(bytes, offset).getUint16(2);
        } else if (payloadLength == 127) {
          payloadLength = ByteData.sublistView(bytes, offset).getUint64(2);
        }

        if (opcode == null) {
          fail(WebsocketProtocolException('Unknown opcode: ${b1 & 0x0F}.'));
          break;
        }

        if (opcode.isControl && (!fin || payloadLength > 125)) {
          fail(
            WebsocketProtocolException(
              'Control frames must not be fragmented or carry more than '
              '125 bytes of payload.',
            ),
          );
          break;
        }

        if (requireMask && !masked) {
          fail(
            WebsocketProtocolException(
              'Client-to-server frames must be masked.',
            ),
          );
          break;
        }

        // payloadLength < 0 catches 64-bit lengths overflowing Dart's
        // signed int
        if (payloadLength < 0 || payloadLength > maxFrameSize) {
          fail(
            WebsocketProtocolException(
              'Frame payload exceeds maximum of $maxFrameSize bytes.',
              1009,
            ),
          );
          break;
        }

        final frameSize = headerSize + payloadLength;
        if (remaining < frameSize) {
          needed = frameSize;
          break;
        }

        final payloadOffset = offset + headerSize;
        final payload = Uint8List.fromList(
          Uint8List.sublistView(
            bytes,
            payloadOffset,
            payloadOffset + payloadLength,
          ),
        );

        if (masked) {
          final maskOffset = payloadOffset - 4;
          for (var i = 0; i < payload.length; i++) {
            payload[i] ^= bytes[maskOffset + (i % 4)];
          }
        }

        controller.add(WebsocketFrame(opcode, payload, fin: fin));
        offset += frameSize;
        needed = 2;
      }

      if (!failed && offset < bytes.length) {
        buffer.add(Uint8List.sublistView(bytes, offset));
      }
    }

    controller.onListen = () {
      subscription = stream.listen(
        onData,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onPause = subscription!.pause;
      controller.onResume = subscription!.resume;
      controller.onCancel = subscription!.cancel;
    };

    return controller.stream;
  }
}

class WebsocketFrameEncoder
    extends StreamTransformerBase<WebsocketFrame, Uint8List> {
  const WebsocketFrameEncoder();

  @override
  Stream<Uint8List> bind(Stream<WebsocketFrame> stream) {
    return stream.map(encodeFrame);
  }

  Uint8List encodeFrame(WebsocketFrame frame) {
    var headerSize = 2;
    final payloadLength = frame.payload.length;
    var lengthValue = payloadLength;

    if (payloadLength >= 65536) {
      headerSize += 8;
      lengthValue = 127;
    } else if (payloadLength >= 126) {
      headerSize += 2;
      lengthValue = 126;
    }

    final data = Uint8List(headerSize + payloadLength);
    var b1 = frame.opcode.value;
    if (frame.fin) {
      b1 |= 0x80;
    }
    data[0] = b1;
    data[1] = lengthValue; // Server to client NEVER masks.

    var offset = 2;
    if (lengthValue == 126) {
      data.buffer.asByteData().setUint16(2, payloadLength);
      offset += 2;
    } else if (lengthValue == 127) {
      data.buffer.asByteData().setUint64(2, payloadLength);
      offset += 8;
    }

    data.setAll(offset, frame.payload);
    return data;
  }
}
