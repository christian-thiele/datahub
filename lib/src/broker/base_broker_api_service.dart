import 'dart:convert';

import 'package:cl_datahub/cl_datahub.dart';
import 'package:dart_amqp/dart_amqp.dart';

import 'broker_service.dart';
import 'consumer_exception.dart';

//TODO handle reconnects (channel based and connection based)
abstract class BaseBrokerApiService implements BaseService {
  final _log = resolve<LogService>();
  late final BrokerService _brokerService;
  final bool concurrent;
  final _channels = <Channel>[];

  //TODO concurrency
  BaseBrokerApiService({
    this.concurrent = false,
  });

  @override
  Future<void> initialize() async {
    final service = ServiceHost.tryResolve<BrokerService>();
    if (service == null) {
      _log.e(
          'A BrokerService is required to start the BrokerAPI. Try placing a BrokerService implementation before this service to your ServiceHost.');
      throw Exception('No BrokerService found in ServiceHost.');
    }
    _brokerService = service;
  }

  //TODO docs should be somewhere else since this is kinda internal
  /// This provides a consumer-queue oriented fan-out model.
  ///
  /// An exchange and a consumer queue is created and bound together.
  /// Multiple consumers can add and bind their queues to this exchange.
  ///
  /// The BrokerApiClient will publish messages to the exchange and every
  /// message will be delivered to every consumer.
  ///
  /// If no consumers are running, messages will be lost.
  /// To "rescue" those messages an "alternate exchange" can be used.
  ///
  /// Queues are created with durable=false, autoDelete=true
  Future<void> initializeFanOutExchange(
      String exchangeName, String? consumerTag) async {
    final channel = await _brokerService.openChannel();
    final exchange = await channel.exchange(exchangeName, ExchangeType.FANOUT);
    final queue = await channel.queue('', autoDelete: true);
    await queue.bind(exchange, '');
    final consumer =
        await queue.consume(consumerTag: consumerTag, noAck: false);
    consumer.listen(_onData);
  }

  /// This provides a producer-queue, competing consumer model.
  ///
  /// The consumer subscribes to a queue together with other potential consumers
  /// while messages are distributed between them by the broker. Every message
  /// is processed by only one consumer.
  ///
  /// RPC endpoints always use this model.
  Future<void> initializeCompetingConsumer(
      String queueName, bool durable, String? consumerTag) async {
    final channel = await _brokerService.openChannel();
    _channels.add(channel);
    final queue =
        await channel.queue(queueName, durable: durable, autoDelete: false);
    final consumer =
        await queue.consume(consumerTag: consumerTag, noAck: false);
    consumer.listen(_onData);
  }

  Future<void> _onData(AmqpMessage event) async {
    try {
      if (event.properties?.headers?['datahub-invocation'] is! String) {
        throw Exception('Payload does not contain datahub-invocation header.');
      }

      final invocation =
          event.properties!.headers!['datahub-invocation'] as String;

      final decoded = () {
        if (event.payload == null) {
          return null;
        }

        return JsonDecoder().convert(utf8.decode(event.payload!));
      }();

      try {
        final reply = await onMessage(invocation, decoded);

        if (reply != null) {
          event.reply(JsonEncoder().convert(reply));
        }
      } catch (e, stack) {
        _onError(event, invocation, e, stack);
      }

      event.ack();
    } catch (e, stack) {
      _log.error(
        'Could not process message.',
        sender: 'DataHub',
        error: e,
        trace: stack,
      );
      event.reject((e is ConsumerException) ? e.requeue : false);
    }
  }

  /// When return value is non-null, a reply is sent using the reply-queue.
  Future<Map<String, dynamic>?> onMessage(String invocation, dynamic payload);

  @override
  Future<void> shutdown() async {
    for (final channel in _channels) {
      await channel.close();
    }
  }

  void _onError(
      AmqpMessage event, String endpointName, dynamic e, StackTrace stack) {
    if (e is ConsumerException) {
      throw e; // this is handled above and will reject the message
    }

    if (event.properties?.replyTo != null) {
      if (e is ApiRequestException) {
        event.reply({'error': e.message, 'errorCode': e.statusCode});
      } else if (e is ApiException) {
        event.reply({'error': e.message});
      } else {
        event.reply({'error': e.toString()});
      }
    }

    _log.error(
      'Error while handling message to $endpointName.',
      sender: 'DataHub',
      error: e,
      trace: stack,
    );
  }
}
