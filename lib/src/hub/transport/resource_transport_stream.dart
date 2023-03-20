import 'dart:async';
import 'dart:typed_data';

import 'package:boost/boost.dart';

import 'resource_transport_exception.dart';
import 'resource_transport_message.dart';

class ResourceTransportReadTransformer
    extends StreamTransformerBase<List<int>, ResourceTransportMessage> {
  _MessageHead? _header;
  final buffer = <int>[];

  late final StreamSubscription _subscription;
  late final _controller = StreamController<ResourceTransportMessage>(
    onCancel: () => _subscription.cancel(),
    onPause: () => _subscription.pause(),
    onResume: () => _subscription.resume(),
  );

  @override
  Stream<ResourceTransportMessage> bind(Stream<List<int>> stream) {
    _subscription = stream.listen(
      onData,
      onError: _controller.addError,
      onDone: _controller.close,
      cancelOnError: true,
    );
    return _controller.stream;
  }

  void onData(List<int> event) {
    try {
      buffer.addAll(event);

      if (_header == null) {
        if (buffer.length >= _MessageHead.transportHeaderLength) {
          if (!buffer.take(3).sequenceEquals(_MessageHead.transportPreface)) {
            throw ResourceTransportException('Invalid preface.');
          }

          final version = buffer[3];
          if (version != _MessageHead.transportVersion) {
            throw ResourceTransportException(
                'Invalid transport version. (received: $version, expected: ${_MessageHead.transportVersion})');
          }

          _header = _MessageHead.read(_byteData(
              buffer.take(_MessageHead.transportHeaderLength).toList()));
        }
      }

      if (_header != null) {
        final targetLength =
            _MessageHead.transportHeaderLength + _header!.payloadLength;
        if (buffer.length >= targetLength) {
          final payload =
              buffer.sublist(_MessageHead.transportHeaderLength, targetLength);
          buffer.removeRange(0, targetLength);
          _controller.add(ResourceTransportMessage(
              _header!.resourceType, _header!.messageType, payload));
          _header = null;
        }
      }
    } catch (e, stack) {
      _subscription.cancel();
      _controller.addError(e, stack);
      _controller.close();
    }
  }

  static ByteData _byteData(List<int> data) {
    if (data is Uint8List) {
      return ByteData.sublistView(data);
    } else {
      return ByteData.sublistView(Uint8List.fromList(data));
    }
  }
}

class ResourceTransportWriteTransformer
    extends StreamTransformerBase<ResourceTransportMessage, List<int>> {
  @override
  Stream<List<int>> bind(Stream<ResourceTransportMessage> stream) =>
      stream.map(_encodeMessage);

  List<int> _encodeMessage(ResourceTransportMessage event) {
    final buffer =
        Uint8List(_MessageHead.transportHeaderLength + event.payload.length);
    _MessageHead(event.resourceType, event.messageType, event.payload.length)
        .write(buffer, 0);
    buffer.setRange(
        _MessageHead.transportHeaderLength, buffer.length, event.payload);
    return buffer;
  }
}

class _MessageHead {
  static const transportPreface = [0x44, 0x48, 0x52];
  static const transportVersion = 0x02;
  static const transportHeaderLength = 16;

  final ResourceTransportResourceType resourceType;
  final ResourceTransportMessageType messageType;
  final int payloadLength;

  _MessageHead(this.resourceType, this.messageType, this.payloadLength);

  factory _MessageHead.read(ByteData data) {
    final resourceType =
        ResourceTransportResourceType.fromByte(data.getUint8(4));
    final messageType = ResourceTransportMessageType.fromByte(data.getUint8(5));
    // 6-7 reserved
    final payloadLength = data.getUint32(8, Endian.big);
    // 12-15 padding
    return _MessageHead(resourceType, messageType, payloadLength);
  }

  void write(Uint8List buffer, int offset) {
    buffer.setRange(offset, offset + transportHeaderLength,
        Iterable.generate(transportHeaderLength, (i) => 0));

    buffer.setRange(offset, offset + 3, transportPreface);
    final data = ByteData.sublistView(buffer);
    data.setUint8(offset + 3, transportVersion);
    data.setUint8(offset + 4, resourceType.byte);
    data.setUint8(offset + 5, messageType.byte);
    // 5-7 reserved
    data.setUint32(offset + 8, payloadLength, Endian.big);
    // 12-15 padding
  }
}
