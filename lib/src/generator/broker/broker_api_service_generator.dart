import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:boost/boost.dart';
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
    final interfaceAnnotation = assertBrokerInterface(classElement.supertype);

    final queueName = readField<String>(interfaceAnnotation, 'queueName')!;
    final durable = readField<bool>(interfaceAnnotation, 'durable')!;

    final implMethods = classElement.methods.where((m) => !m.isPrivate);
    final intMethods =
        classElement.supertype!.element.methods.where((m) => !m.isPrivate);

    // Use implementation method (for return type, which can differ for void / Future<void>)
    // combined with the parameter names of the interface to avoid runtime errors when parsing
    // broker messages.
    final endpointMethods = intMethods.map((m) =>
        Tuple(implMethods.firstWhere((e) => e.name == m.name), m.parameters));

    final endpoints = endpointMethods
        .map((m) => BrokerApiEndpoint.fromMethod(m.a, m.b))
        .toList();

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

  /// Checks if interface is BrokerInterface and returns the BrokerInterface annotation.
  DartObject assertBrokerInterface(InterfaceType? supertype) {
    if (supertype == null) {
      throw Exception(
          'BrokerApi annotated class must extend BrokerInterface annotated class.');
    }
    final interfaceAnnotation =
        getAnnotation(supertype.element, BrokerInterface);
    if (interfaceAnnotation == null) {
      throw Exception(
          'BrokerApi annotated class must extend BrokerInterface annotated class.');
    }
    return interfaceAnnotation;
  }
}
