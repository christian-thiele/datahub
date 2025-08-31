import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element2.dart';
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
