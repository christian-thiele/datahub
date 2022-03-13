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
    final returnType = endpoint.returnTypeStatement;
    final params = endpoint.params.map((e) => e.paramStatement).join(', ');
    final suffix = endpoint.isRpc ? 'async ' : '';

    yield '@override $returnType ${endpoint.name}($params) $suffix{';
    yield 'final encodedPayload = {';
    for (final param in endpoint.params) {
      yield "'${param.name}': ${param.encodingStatement(param.name)},";
    }
    yield '};';

    yield 'final jsonPayload = encodeJsonString(encodedPayload);';
    if (endpoint.isRpc) {
      yield 'final correlationId = uuid();';
      yield 'final replyFuture = waitForReply(correlationId);';

      yield "_exchange.publish(jsonPayload, '', properties: MessageProperties()"
          "..headers = {'datahub-invocation': '${endpoint.name}'}"
          '..replyTo=replyQueueName'
          '..corellationId=correlationId);';

      yield 'final replyPayload = (await replyFuture).payloadAsJson;';
      yield "if (replyPayload.containsKey('error')) {";
      yield "final errorCode = (replyPayload['errorCode'] is int) ? "
          "replyPayload['errorCode'] : null;";
      yield "throw BrokerApiException(replyPayload['error'].toString(), "
          'errorCode: errorCode);';
      yield '}';
      final decode = endpoint.replyType!
          .buildDecodingStatement("replyPayload['result']", false);
      yield 'return $decode;';
    } else {
      yield "_exchange.publish(jsonPayload, '', properties: MessageProperties()"
          "..headers = {'datahub-invocation': '${endpoint.name}'});";
    }

    yield '}';
  }
}
