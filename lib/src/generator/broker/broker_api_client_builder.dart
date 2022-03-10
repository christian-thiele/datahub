import 'package:cl_datahub/src/generator/broker/broker_api_endpoint.dart';

class BaseApiClientBuilder {
  final String interfaceClass;
  final List<BrokerApiEndpoint> endpoints;
  final String queueName;
  final bool durable;

  BaseApiClientBuilder(
      this.interfaceClass, this.endpoints, this.queueName, this.durable);

  Iterable<String> build() sync* {
    yield 'class ${interfaceClass}Client extends BaseBrokerClientService implements $interfaceClass {';
    yield 'late final Exchange _exchange;';
    yield* buildInitializeMethod();
    yield* buildOverrides();
    yield '}';
  }

  Iterable<String> buildInitializeMethod() sync* {
    yield '@override Future<void> initialize() async { await super.initialize();';
    // for every fanout:
    // exchange_${endpoint.name} = await channel.exchange(${endpoint.name}, ExchangeType.FANOUT);

    // for every producer-queue
    // exchange_${endpoint.name} = await channel.exchange(exchangeName, ExchangeType.FANOUT);
    // final queue = await _channel.queue('{endpoint.name}', durable: durable, autoDelete: false);
    // await queue.bind(exchange, '');

    yield "_exchange = await channel.exchange('ex_$queueName', ExchangeType.FANOUT);";
    yield "final queue = await channel.queue('$queueName', durable: $durable, autoDelete: false);";
    yield "await queue.bind(_exchange, '');";

    if (endpoints.any((e) => e.isRpc)) {
      yield 'await setupReplyQueue();';
    }

    yield '}';
  }

  Iterable<String> buildOverrides() sync* {
    for (final endpoint in endpoints) {
      yield* buildEndpointOverride(endpoint);
    }
  }

  Iterable<String> buildEndpointOverride(BrokerApiEndpoint endpoint) sync* {
    final returnType = endpoint.isRpc
        ? (endpoint.isAsync
            ? 'Future<${endpoint.replyType!.typeName}>'
            : endpoint.replyType!.typeName)
        : 'void';
    final param = endpoint.payloadType != null
        ? (endpoint.payloadType!.typeName + ' ' + endpoint.payloadName!)
        : '';

    final prefix = endpoint.isRpc ? 'async ' : '';

    yield '@override $returnType ${endpoint.name}($param) $prefix{';
    if (endpoint.payloadType != null) {
      final encode = endpoint.payloadType!
          .buildEncodingStatement(endpoint.payloadName!, false);

      yield 'final encodedPayload = $encode;';
      yield 'final jsonPayload = encodeJsonString(encodedPayload);';
      if (endpoint.isRpc) {
        yield 'final correlationId = uuid();';
        yield 'final replyFuture = waitForReply(correlationId);';

        yield "_exchange.publish(jsonPayload, '', properties: MessageProperties()"
            "..headers = {'datahub-invocation': '${endpoint.name}'}"
            '..replyTo=replyQueueName'
            '..corellationId=correlationId);';

        yield 'final replyPayload = (await replyFuture).payloadAsJson;';
        final decode = endpoint.replyType!.buildDecodingStatement(
            'replyPayload as Map<String, dynamic>', false);
        yield 'return $decode;';
      } else {
        yield "_exchange.publish(jsonPayload, '', properties: MessageProperties()"
            "..headers = {'datahub-invocation': '${endpoint.name}'});";
      }
    }
    yield '}';
  }
}
