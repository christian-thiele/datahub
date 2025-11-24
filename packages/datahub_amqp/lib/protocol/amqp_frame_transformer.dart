import 'dart:async';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_amqp/protocol/amqp_exception.dart';

import 'amqp_frame.dart';
import 'constants.dart';

class _FrameHeader {
  final int type;
  final int channelId;
  final int bodySize;

  _FrameHeader(this.type, this.channelId, this.bodySize);
}

class AmqpFrameTransformer extends StreamTransformerBase<Uint8List, AmqpFrame> {
  late final StreamSubscription subscription;
  final controller = StreamController<AmqpFrame>();
  final _reader = ByteDataReader(endian: Endian.big);
  _FrameHeader? _currentFrame;

  AmqpFrameTransformer();

  @override
  Stream<AmqpFrame> bind(Stream<List<int>> stream) {
    controller.onListen = () {
      subscription = stream.listen(
        onData,
        onError: controller.addError,
        onDone: controller.close,
        cancelOnError: true,
      );
      controller.onCancel = subscription.cancel;
    };
    return controller.stream;
  }

  void onData(List<int> event) {
    try {
      _reader.add(event);
      if (_currentFrame == null && _reader.remainingLength >= 7) {
        _currentFrame = _FrameHeader(
          _reader.readUint8(),
          _reader.readUint16(),
          _reader.readUint32(),
        );
      }

      if (_currentFrame case _FrameHeader(
        :final type,
        :final channelId,
        :final bodySize,
      ) when _reader.remainingLength >= bodySize + 1) {
        final body = _reader.read(bodySize);
        if (_reader.readUint8() == frameEnd) {
          try {
            controller.add(switch (type) {
              frameMethod => MethodFrame.parseBody(channelId, body),
              frameHeader => HeaderFrame.parseBody(channelId, body),
              frameBody => BodyFrame.parseBody(channelId, body),
              frameHeartbeat => const HeartbeatFrame(),
              _ => throw AmqpException(
                errorCode: frameError,
                message: 'Received malformed frame.',
              ),
            });
            _currentFrame = null;
          } on StateError catch (_) {
            throw AmqpException(
              errorCode: frameError,
              message: 'Received malformed frame.',
            );
          }
        } else {
          throw AmqpException(
            errorCode: frameError,
            message: 'Received malformed frame.',
          );
        }
      }
    } catch (e, stack) {
      controller.addError(e, stack);
      subscription.cancel();
    }
  }
}
