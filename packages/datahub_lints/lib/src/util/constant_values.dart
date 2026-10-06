import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';

import 'query_groups.dart';

/// The expression of the named argument [name] of [node], if passed.
Expression? namedArgument(InstanceCreationExpression node, String name) {
  for (final argument in node.argumentList.arguments) {
    if (argument is NamedArgument && argument.name.lexeme == name) {
      return argument.argumentExpression;
    }
  }
  return null;
}

/// The [index]th positional argument of [node], if passed.
Expression? positionalArgument(InstanceCreationExpression node, int index) =>
    node.argumentList.arguments
        .where((a) => a is! NamedArgument)
        .whereType<Expression>()
        .elementAtOrNull(index);

/// The value of [expression] if it is a constant expression.
///
/// Arguments of a non-const invocation are evaluated all the same, as long as
/// they are constant expressions themselves.
DartObject? constantValueOf(Expression expression) {
  final result = expression.computeConstantValue();
  if (result == null || result.diagnostics.isNotEmpty) {
    return null;
  }
  return result.value;
}

int? intValueOf(Expression expression) =>
    constantValueOf(expression)?.toIntValue();

String? stringValueOf(Expression expression) =>
    constantValueOf(expression)?.toStringValue();

/// The name of the enum value [expression] evaluates to.
String? enumNameOf(Expression expression) =>
    constantValueOf(expression)?.getField('_name')?.toStringValue();

/// Whether [expression] is the literal `null`.
bool isNullLiteral(Expression expression) =>
    unparenthesized(expression) is NullLiteral;

/// Whether [expression] is a list that is known to be empty.
bool isEmptyList(Expression expression) {
  final literal = unparenthesized(expression);
  if (literal is ListLiteral) {
    return literal.elements.isEmpty;
  }
  return constantValueOf(expression)?.toListValue()?.isEmpty ?? false;
}

/// The value of a `Duration` [expression].
///
/// `Duration(...)` without `const` is no constant expression, but it is the
/// common way of writing one, so it is evaluated from its arguments.
Duration? durationValueOf(Expression expression) {
  final node = unparenthesized(expression);
  if (!_isDuration(node.staticType)) {
    return null;
  }

  // The field holding the microseconds was renamed across SDK versions.
  final value = constantValueOf(node);
  final constant =
      (value?.getField('inMicroseconds') ?? value?.getField('_duration'))
          ?.toIntValue();
  if (constant != null) {
    return Duration(microseconds: constant);
  }

  if (node is! InstanceCreationExpression ||
      node.constructorName.name != null) {
    return null;
  }

  var microseconds = 0;
  for (final argument in node.argumentList.arguments) {
    if (argument is! NamedArgument) {
      return null;
    }
    final unit = _microsecondsPer[argument.name.lexeme];
    final amount = intValueOf(argument.argumentExpression);
    if (unit == null || amount == null) {
      return null;
    }
    microseconds += unit * amount;
  }
  return Duration(microseconds: microseconds);
}

const _microsecondsPer = {
  'days': Duration.microsecondsPerDay,
  'hours': Duration.microsecondsPerHour,
  'minutes': Duration.microsecondsPerMinute,
  'seconds': Duration.microsecondsPerSecond,
  'milliseconds': Duration.microsecondsPerMillisecond,
  'microseconds': 1,
};

bool _isDuration(DartType? type) =>
    type is InterfaceType &&
    type.element.name == 'Duration' &&
    type.element.library.isDartCore;
