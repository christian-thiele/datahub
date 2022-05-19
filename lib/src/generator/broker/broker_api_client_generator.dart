import 'package:build/build.dart';
import 'package:cl_datahub/broker.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'broker_api_client_builder.dart';
import 'broker_api_endpoint.dart';

import '../utils.dart';

class BrokerApiClientGenerator extends GeneratorForAnnotation<BrokerInterface> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final classElement = assertClass(element);
    final queueName = annotation.read('queueName').literalValue as String;
    final queueDurable = annotation.read('durable').literalValue as bool;

    final endpoints = classElement.methods
        .where((m) => !m.isPrivate)
        .map((m) => BrokerApiEndpoint.fromMethod(m, m.parameters))
        .toList();

    return BaseApiClientBuilder(
            classElement.name, endpoints, queueName, queueDurable)
        .build()
        .join('\n');
  }
}
