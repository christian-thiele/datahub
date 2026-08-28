import 'package:analyzer/dart/ast/ast.dart';

/// The `ServiceInstance` lifecycle methods, which return `FutureOr<void>` and
/// are annotated `@mustCallSuper`.
const lifecycleMethods = {'initialize', 'dispose'};

/// Whether [node] declares an override of the lifecycle method [method].
bool isLifecycleOverride(MethodDeclaration node, String method) =>
    !node.isStatic &&
    !node.isGetter &&
    !node.isSetter &&
    node.name.lexeme == method;

/// Whether [expression] is a call to `super.<method>()`, with or without
/// `await`.
bool isSuperCall(Expression expression, String method) {
  var target = expression;
  if (target is AwaitExpression) {
    target = target.expression;
  }

  return target is MethodInvocation &&
      target.target is SuperExpression &&
      target.methodName.name == method;
}

/// The statement calling `super.<method>()` directly in [body], or `null`.
///
/// Only statements that are direct children of the method body count. A super
/// call nested inside an `if` or a `try` has no well-defined position among
/// its siblings, so the position rules leave those alone — the analyzer's own
/// `must_call_super` still covers whether the call happens at all.
Statement? superCallStatementIn(FunctionBody body, String method) {
  if (body is! BlockFunctionBody) {
    return null;
  }

  for (final statement in body.block.statements) {
    if (statement is ExpressionStatement &&
        isSuperCall(statement.expression, method)) {
      return statement;
    }
  }

  return null;
}
