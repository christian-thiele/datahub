import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:cl_datahub/src/generator/broker/endpoint_param.dart';

import '../transfer_bean/field_type.dart';

class BrokerApiEndpoint {
  final String name;
  final List<EndpointParam> params;
  final FieldType? replyType;
  final bool isAsync;

  bool get isRpc => replyType != null;

  String get returnTypeStatement =>
      isRpc ? 'Future<${replyType!.typeName}>' : 'void';

  BrokerApiEndpoint(
    this.name,
    this.params,
    this.replyType,
    this.isAsync,
  );

  factory BrokerApiEndpoint.fromMethod(
      MethodElement m, List<ParameterElement> parameters) {
    final params = parameters.map((p) => EndpointParam.fromParam(p)).toList();
    final replyType = findReplyType(m);
    if (!endpointIsAsyncOrVoid(m)) {
      throw Exception('Endpoint return types must be of type Future. '
          '${m.name} has a non-Future return type.');
    }
    final isAsync = endpointIsAsync(m);

    return BrokerApiEndpoint(
      m.name,
      params,
      replyType,
      isAsync,
    );
  }
}

FieldType? findPayloadType(MethodElement m) {
  if (m.parameters.length > 1) {
    throw Exception('Endpoint method "${m.name}" has more than 1 parameter. '
        'Try wrapping values into a TransferObject.');
  }

  if (m.parameters.isEmpty) {
    return null;
  }

  return FieldType.fromDartType(m.parameters.single.type);
}

String? findPayloadName(MethodElement m) {
  if (m.parameters.length > 1) {
    throw Exception('Endpoint method "${m.name}" has more than 1 parameter. '
        'Try wrapping values into a TransferObject.');
  }

  if (m.parameters.isEmpty) {
    return null;
  }

  return m.parameters.single.name;
}

FieldType? findReplyType(MethodElement m) {
  if (m.returnType.isVoid) {
    return null;
  }

  if (m.returnType.isDartAsyncFuture || m.returnType.isDartAsyncFutureOr) {
    final argType = (m.returnType as ParameterizedType).typeArguments.first;
    if (argType.isVoid) {
      return null;
    }
    return FieldType.fromDartType(argType);
  }

  return FieldType.fromDartType(m.returnType);
}

bool endpointIsAsync(MethodElement m) {
  return m.returnType.isDartAsyncFuture || m.returnType.isDartAsyncFutureOr;
}

bool endpointIsAsyncOrVoid(MethodElement m) {
  return m.returnType.isDartAsyncFuture ||
      m.returnType.isDartAsyncFutureOr ||
      m.returnType.isVoid;
}
