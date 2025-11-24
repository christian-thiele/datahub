import 'dart:async';
import 'dart:io';

import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';
import 'package:datahub_amqp/protocol/amqp_frame.dart';
import 'package:datahub_amqp/protocol/plain_authentication.dart';
import 'package:datahub_amqp/utils/stream_reader.dart';
import 'package:rxdart/rxdart.dart';

import 'amqp_frame_transformer.dart';
import 'amqp_method.dart';

part 'channel.dart';

class Connection {
  static const protocolHeader = [65, 77, 81, 80, 0, 0, 9, 1];
  final int channelMax;
  final int frameMax;
  final Duration heartbeatDuration;

  final IOSink _out;
  bool _isOpen = true;

  Connection._({
    required this.channelMax,
    required this.frameMax,
    required this.heartbeatDuration,
    required IOSink out,
  }) : _out = out;

  static Future<Connection> open({
    required String host,
    required int port,
  }) async {
    final socket = await Socket.connect(host, port);
    try {
      final controller = StreamController<AmqpFrame>.broadcast();
      socket.transform(AmqpFrameTransformer()).pipe(controller);
      final streamReader = StreamReader(controller.stream);

      socket.add(protocolHeader);

      Future<AmqpMethod> nextMethod() async {
        final frame = await streamReader.next as MethodFrame;
        return AmqpMethod.fromFrame(frame);
      }

      final startMethod = await nextMethod() as AmqpMethodConnectionStart;
      if (!startMethod.mechanisms.contains('PLAIN')) {
        throw Exception('Server does not support plain authentication.');
      }

      socket.add(
        AmqpMethodConnectionStartOk(
          channelId: 0,
          clientProperties: {},
          mechanism: 'PLAIN',
          response: PlainAuthentication(
            username: 'guest',
            password: 'guest',
          ).toBytes(),
          locale: startMethod.locales.first,
        ).toFrame().pack(),
      );

      final tune = await nextMethod() as AmqpMethodConnectionTune;

      final tuneOk = AmqpMethodConnectionTuneOk(
        channelId: 0,
        channelMax: tune.channelMax,
        frameMax: tune.frameMax,
        heartbeat: tune.heartbeat,
      );
      socket.add(tuneOk.toFrame().pack());
      socket.add(
        AmqpMethodConnectionOpen(
          channelId: 0,
          virtualHost: '/',
        ).toFrame().pack(),
      );

      final openOk = await nextMethod() as AmqpMethodConnectionOpenOk;

      final connection = Connection._(
        channelMax: tune.channelMax,
        frameMax: tune.frameMax,
        heartbeatDuration: Duration(seconds: tune.heartbeat),
        out: socket,
      );

      controller.stream.listen(
        connection._onFrame,
        onDone: connection._onDone,
        onError: connection._onSocketError,
      );

      return connection;
    } catch (_) {
      await socket.close();
      rethrow;
    }
  }

  Future<void> close() async {
    if (_isOpen) {
      _isOpen = false;
      _out.add(
        AmqpMethodConnectionClose(
          channelId: 0,
          replyCode: 0,
          replyText: '',
          failingClassId: 0,
          failingMethodId: 0,
        ).toFrame().pack(),
      );
      await _out.done;
    }
  }

  void _onFrame(AmqpFrame data) async {
    log.trace(data.toString());
    if (data is MethodFrame) {
      final method = AmqpMethod.fromFrame(data);
      if (method is AmqpMethodConnectionCloseOk) {
        _isOpen = false;
        await _out.close();
        return;
      }
    }
  }

  void _onDone() {
    _isOpen = false;
    // TODO close channels
  }

  void _onSocketError(dynamic e, StackTrace stack) {
    _isOpen = false;
    // TODO close channels
    log.error('AMQP Connection error', error: e, stack: stack);
  }
}
