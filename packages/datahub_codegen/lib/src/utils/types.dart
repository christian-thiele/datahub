import 'package:analyzer/dart/element/type.dart';

String typeExpression(DartType type) {
  return switch (type) {
    ParameterizedType(:final typeArguments, :final element?)
        when typeArguments.isNotEmpty =>
      '${element.displayName}<${typeArguments.map(typeExpression).join(', ')}>',
    DartType(:final element?) => element.displayName,
    DartType() => type.getDisplayString(),
    _ => 'dynamic',
  };
}
