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

  static WebsocketOpcode fromValue(int value) {
    return WebsocketOpcode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw Exception('Unknown opcode: $value'),
    );
  }
}

class WebsocketFrame {
  final bool fin;
  final WebsocketOpcode opcode;
  final Uint8List payload;

  String get text => utf8.decode(payload);

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
    final reasonBytes = reason != null ? utf8.encode(reason) : Uint8List(0);
    final payload = Uint8List(2 + reasonBytes.length);
    payload.buffer.asByteData().setUint16(0, code);
    payload.setAll(2, reasonBytes);
    return payload;
  }
}

class WebsocketFrameDecoder
    extends StreamTransformerBase<Uint8List, WebsocketFrame> {
  const WebsocketFrameDecoder();

  @override
  Stream<WebsocketFrame> bind(Stream<Uint8List> stream) {
    final controller = StreamController<WebsocketFrame>();
    final buffer = <int>[];

    void onData(Uint8List data) {
      buffer.addAll(data);

      while (buffer.length >= 2) {
        final b1 = buffer[0];
        final b2 = buffer[1];

        final fin = (b1 & 0x80) != 0;
        final opcodeValue = b1 & 0x0F;
        final mask = (b2 & 0x80) != 0;
        var payloadLength = b2 & 0x7F;

        var headerSize = 2;
        if (payloadLength == 126) {
          headerSize += 2;
        } else if (payloadLength == 127) {
          headerSize += 8;
        }

        if (mask) {
          headerSize += 4;
        }

        if (buffer.length < headerSize) return;

        var offset = 2;
        if (payloadLength == 126) {
          payloadLength = ByteData.sublistView(
            Uint8List.fromList(buffer),
            2,
            4,
          ).getUint16(0);
          offset += 2;
        } else if (payloadLength == 127) {
          payloadLength = ByteData.sublistView(
            Uint8List.fromList(buffer),
            2,
            10,
          ).getUint64(0);
          offset += 8;
        }

        final List<int>? maskingKey;
        if (mask) {
          maskingKey = buffer.sublist(offset, offset + 4);
          offset += 4;
        } else {
          maskingKey = null;
        }

        if (buffer.length < offset + payloadLength) return;

        final payload = Uint8List.fromList(
          buffer.sublist(offset, offset + payloadLength),
        );
        buffer.removeRange(0, offset + payloadLength);

        if (maskingKey != null) {
          for (var i = 0; i < payload.length; i++) {
            payload[i] ^= maskingKey[i % 4];
          }
        }

        try {
          final opcode = WebsocketOpcode.fromValue(opcodeValue);
          controller.add(WebsocketFrame(opcode, payload, fin: fin));
        } catch (e) {
          controller.addError(e);
        }
      }
    }

    controller.onListen = () {
      final subscription = stream.listen(
        onData,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onPause = subscription.pause;
      controller.onResume = subscription.resume;
      controller.onCancel = subscription.cancel;
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
