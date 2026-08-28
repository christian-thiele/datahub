import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/service_instance.dart';

/// The `ServiceInstance` lifecycle methods, which return `FutureOr<void>`.
const _lifecycleMethods = {'initialize', 'dispose'};

/// Reports `super.initialize()` / `super.dispose()` calls that are not awaited.
///
/// Both return `FutureOr<void>`, so dropping the future lets the override
/// continue before the base class finished assigning its `late final` state.
class AwaitLifecycleSuperRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'await_lifecycle_super',
    "Does not await 'super.{0}()'.",
    correctionMessage:
        "Try adding 'await', so that the base class finishes before the "
        'override continues.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.await_lifecycle_super',
  );

  AwaitLifecycleSuperRule()
    : super(
        name: 'await_lifecycle_super',
        description:
            'The ServiceInstance lifecycle methods return FutureOr<void>. An '
            'override that does not await the super call may run before the '
            'base class has finished initializing or disposing.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (!_lifecycleMethods.contains(name)) {
      return;
    }

    if (node.target is! SuperExpression) {
      return;
    }

    if (!isInServiceInstanceMember(node)) {
      return;
    }

    // Anything other than a bare expression statement already consumes the
    // future: `await super.x()`, `return super.x()`, `unawaited(super.x())`.
    if (node.parent is! ExpressionStatement) {
      return;
    }

    rule.reportAtNode(node, arguments: [name]);
  }
}
