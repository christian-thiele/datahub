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
    yield '}';
  }

  Iterable<String> buildOnMessageMethod() sync* {
    yield '@override Future<dynamic> onMessage(String invocation, dynamic payload) async {';
    for (final endpoint in endpoints) {
      yield "if (invocation == '${endpoint.name}') {";

      var invocation = '_impl.${endpoint.name}()';
      if (endpoint.payloadType != null) {
        final decode =
            endpoint.payloadType!.buildDecodingStatement('payload', false);
        yield 'final decodedPayload = $decode;';
        invocation = '_impl.${endpoint.name}(decodedPayload)';
      }

      if (endpoint.isAsync) {
        invocation = 'await $invocation';
      }

      if (endpoint.isRpc) {
        yield 'final reply = $invocation;';
        final mapEncode =
            endpoint.replyType!.buildEncodingStatement('reply', false);
        yield 'return $mapEncode;';
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
