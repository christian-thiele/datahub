import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../transfer_bean/field_type.dart';

class BrokerApiEndpoint {
  final String name;
  final FieldType? payloadType;
  final FieldType? replyType;
  final String? payloadName;
  final bool isAsync;

  bool get isRpc => replyType != null;

  BrokerApiEndpoint(
    this.name,
    this.payloadName,
    this.payloadType,
    this.replyType,
    this.isAsync,
  );
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
    return FieldType.fromDartType(
        (m.returnType as ParameterizedType).typeArguments.first);
  }

  return FieldType.fromDartType(m.returnType);
}

bool endpointIsAsync(MethodElement m) {
  return m.returnType.isDartAsyncFuture || m.returnType.isDartAsyncFutureOr;
}
