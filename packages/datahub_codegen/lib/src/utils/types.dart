import 'package:analyzer/dart/element/type.dart';

String typeExpression(DartType type) {
  return switch (type) {
    ParameterizedType(:final typeArguments, :final element3?)
        when typeArguments.isNotEmpty =>
      '${element3.displayName}<${typeArguments.map(typeExpression).join(', ')}>',
    DartType(:final element3?) => element3.displayName,
    DartType() => type.getDisplayString(),
  };
}
