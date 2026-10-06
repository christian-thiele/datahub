import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import 'constant_values.dart';
import 'datahub_types.dart';

/// An `OnEnter(...)` or `OnSignal(...)` workflow step.
sealed class StepCreation {
  final InstanceCreationExpression node;

  StepCreation(this.node);

  static StepCreation? of(Expression expression) {
    if (expression is! InstanceCreationExpression) {
      return null;
    }

    final type = expression.staticType;
    if (isType(type, 'OnEnter')) {
      return OnEnterCreation(expression);
    }
    if (isType(type, 'OnSignal')) {
      return OnSignalCreation(expression);
    }
    return null;
  }

  /// The `name` argument, if passed.
  Expression? get nameArgument => namedArgument(node, 'name');

  Expression? get failureState => namedArgument(node, 'failureState');

  /// The name of the step as `WorkflowStep.name` returns it, or `null` if it
  /// can not be determined statically.
  String? get name {
    final argument = nameArgument;
    if (argument == null || isNullLiteral(argument)) {
      return defaultName;
    }
    return stringValueOf(argument);
  }

  String? get defaultName;

  /// The node a diagnostic about the step as a whole is reported at.
  AstNode get reportNode => nameArgument ?? node.constructorName;
}

final class OnEnterCreation extends StepCreation {
  OnEnterCreation(super.node);

  Expression? get state => positionalArgument(node, 0);

  Expression? get after => namedArgument(node, 'after');

  Expression? get at => namedArgument(node, 'at');

  /// The delay, `null` if it can not be determined statically.
  Duration? get delay {
    final argument = after;
    return argument == null ? Duration.zero : durationValueOf(argument);
  }

  /// Whether the step runs at a time taken from the element, `null` if that
  /// can not be determined statically.
  bool? get hasTime {
    final argument = at;
    if (argument == null || isNullLiteral(argument)) {
      return false;
    }
    final type = argument.staticType;
    return type != null && type.nullabilitySuffix == NullabilitySuffix.none
        ? true
        : null;
  }

  @override
  String? get defaultName {
    final state = this.state;
    final stateName = state == null ? null : enumNameOf(state);
    if (stateName == null) {
      return null;
    }

    return switch ((hasTime, delay)) {
      (true, _) => '$stateName at',
      (false, Duration.zero) => stateName,
      (false, final delay?) => '$stateName after $delay',
      _ => null,
    };
  }
}

final class OnSignalCreation extends StepCreation {
  OnSignalCreation(super.node);

  Expression? get signalBean => positionalArgument(node, 0);

  Expression? get accept => namedArgument(node, 'accept');

  Expression? get expireAfter => namedArgument(node, 'expireAfter');

  /// The element type `T` of `OnSignal<T, TState, TSignal>`.
  DartType? get elementType => _typeArgument(0);

  /// The signal type `TSignal` of `OnSignal<T, TState, TSignal>`.
  DartType? get signalType => _typeArgument(2);

  /// The name of the signal bean, which is not a constant.
  @override
  String? get defaultName => null;

  DartType? _typeArgument(int index) {
    final type = node.staticType;
    return type is InterfaceType && type.typeArguments.length == 3
        ? type.typeArguments[index]
        : null;
  }
}
