import 'broker_api_endpoint.dart';

class BrokerApiServiceBuilder {
  final String interfaceClass;
  final String implementationClass;
  final bool concurrent;
  final List<BrokerApiEndpoint> endpoints;
  final String queueName;
  final bool durable;

  BrokerApiServiceBuilder(
    this.interfaceClass,
    this.implementationClass,
    this.concurrent,
    this.endpoints,
    this.queueName,
    this.durable,
  );

  Iterable<String> build() sync* {
    yield 'class ${implementationClass}Service extends BaseBrokerApiService {';
    yield 'final _impl = $implementationClass();';
    yield* buildConstructor();
    yield* buildInitializeMethod();
    yield* buildOnMessageMethod();
    yield '}';
  }

  Iterable<String> buildConstructor() sync* {
    yield '${implementationClass}Service() : super(concurrent: $concurrent);';
  }

  Iterable<String> buildInitializeMethod() sync* {
    yield '@override Future<void> initialize() async { await super.initialize();';
    yield "await initializeCompetingConsumer('$queueName', $durable, null);";
    yield "ServiceHost.tryResolve<LogService>()?.verbose('$implementationClass Service initialized.');";
    yield '}';
  }

  Iterable<String> buildOnMessageMethod() sync* {
    yield '@override Future<Map<String, dynamic>?> onMessage(String invocation, dynamic payload) async {';
    for (final endpoint in endpoints) {
      yield "if (invocation == '${endpoint.name}') {";

      for (final param in endpoint.params) {
        final decode = param.decodingStatement("payload['${param.name}']");
        yield 'final _${param.name} = $decode;';
      }

      final invocation =
          '${endpoint.isAsync ? 'await ' : ''}_impl.${endpoint.name}'
          '(${endpoint.params.map((e) => '_${e.name}').join(', ')})';

      if (endpoint.isRpc) {
        yield 'final reply = $invocation;';
        final mapEncode =
            endpoint.replyType!.buildEncodingStatement('reply', false);
        yield "return {'result': $mapEncode};";
      } else {
        yield '$invocation;';
        yield 'return null;';
      }
      yield '}';
    }

    yield "throw ConsumerException('Invalid invocation name.');";
    yield '}';
  }
}
