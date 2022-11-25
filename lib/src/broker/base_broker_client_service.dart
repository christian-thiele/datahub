import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:dart_amqp/dart_amqp.dart';

@deprecated
abstract class BaseBrokerClientService extends BaseService {
  final _log = resolve<LogService>();
  late final BrokerService _brokerService;
  late final Channel channel;
  Channel? _replyChannel;
  Queue? _replyQueue;
  final _replyCompleter = <String, Completer<AmqpMessage>>{};

  BaseBrokerClientService();

  String get replyQueueName =>
      _replyQueue?.name ?? (throw Exception('Reply queue not initialized.'));

  @override
  Future<void> initialize() async {
    final service = resolve<BrokerService?>();
    if (service == null) {
      _log.e(
          'A BrokerService is required to start the BrokerAPI. Try placing a BrokerService implementation before this service to your ServiceHost.');
      throw Exception('No BrokerService found in ServiceHost.');
    }
    _brokerService = service;
    channel = await _brokerService.openChannel();
  }

  Future<void> setupReplyQueue() async {
    if (_replyChannel != null) {
      throw Exception('Reply Queue already initialized.');
    }
    _replyChannel = await _brokerService.openChannel();
    _replyQueue =
        await _replyChannel!.queue('', durable: false, autoDelete: true);
    final consumer = await _replyQueue!.consume(noAck: false);
    consumer.listen(_onReplyEvent);
  }

  void _onReplyEvent(AmqpMessage event) {
    final correlationId = event.properties?.corellationId;
    if (correlationId == null) {
      _log.error('Message without correlation id received on reply '
          'queue "${_replyQueue?.name}".');
      event.reject(false);
      return;
    }

    if (!_replyCompleter.containsKey(correlationId)) {
      _log.error('Message with unknown correlation id received on reply queue '
          '"${_replyQueue?.name}". [correlationId: $correlationId]');
      event.reject(false);
      return;
    }

    if (_replyCompleter[correlationId]!.isCompleted) {
      _log.warn('Reply to already completed rpc call received on reply queue '
          '"${_replyQueue?.name}", dropping message. '
          '[correlationId: $correlationId]');
      event.reject(false);
      return;
    }

    _replyCompleter[correlationId]!.complete(event);
    event.ack();
  }

  Future<AmqpMessage> waitForReply(String correlationId) async {
    final completer = Completer<AmqpMessage>();
    _replyCompleter[correlationId] = completer;
    return await completer.future;
  }

  @override
  Future<void> shutdown() async {
    await channel.close();
  }
}
