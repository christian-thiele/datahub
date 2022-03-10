import 'package:build/build.dart';
import 'package:cl_datahub/broker.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'broker_api_endpoint.dart';
import 'broker_api_service_builder.dart';

import '../utils.dart';

class BrokerApiServiceGenerator extends GeneratorForAnnotation<BrokerApi> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    final classElement = assertClass(element);
    if (classElement.unnamedConstructor == null) {
      throw Exception(
          'BrokerAPI implementation needs to provide an unnamed constructor.');
    }

    final concurrent = annotation.read('concurrent').literalValue as bool;
    //TODO this should be in interface
    final queueName = annotation.read('queueName').literalValue as String;
    final durable = annotation.read('durable').literalValue as bool;

    final endpoints = classElement.methods.where((m) => !m.isPrivate).map((m) {
      final payloadName = findPayloadName(m);
      final payloadType = findPayloadType(m);
      final replyType = findReplyType(m);
      final isAsync = endpointIsAsync(m);

      return BrokerApiEndpoint(
        m.name,
        payloadName,
        payloadType,
        replyType,
        isAsync,
      );
    }).toList();

    var result = BrokerApiServiceBuilder(
      classElement.name,
      classElement.name,
      concurrent,
      endpoints,
      queueName,
      durable,
    ).build().join('\n\n'); // fix for VERY weird error...

    yield result;
  }
}
