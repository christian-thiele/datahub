import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/lifecycle.dart';
import '../../util/service_instance.dart';

/// Reports `super.initialize()` that is not the first statement.
///
/// The base class assigns the state an override then builds on, so anything
/// running before the super call sees a half-initialized instance.
class SuperInitializeFirstRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'super_initialize_first',
    "'super.initialize()' is not the first statement.",
    correctionMessage:
        'Try moving it to the top, so the base class is initialized before '
        'this override runs.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.super_initialize_first',
  );

  SuperInitializeFirstRule()
    : super(
        name: 'super_initialize_first',
        description:
            'A ServiceInstance sets up its state in initialize(). An override '
            'that runs work before calling the super method sees that state '
            'unassigned.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodDeclaration(
      this,
      _Visitor(this, method: 'initialize', wantFirst: true),
    );
  }
}

/// Reports `super.dispose()` that is not the last statement.
///
/// An override tears down resources that may still depend on the base class,
/// so the super call belongs at the end — the mirror image of [initialize].
class SuperDisposeLastRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'super_dispose_last',
    "'super.dispose()' is not the last statement.",
    correctionMessage:
        'Try moving it to the end, so this override tears down before the '
        'base class does.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.super_dispose_last',
  );

  SuperDisposeLastRule()
    : super(
        name: 'super_dispose_last',
        description:
            'A ServiceInstance tears down in dispose(). An override that '
            'calls the super method before its own cleanup releases the base '
            'class state while it is still in use.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodDeclaration(
      this,
      _Visitor(this, method: 'dispose', wantFirst: false),
    );
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String method;

  /// Whether the super call belongs first; otherwise it belongs last.
  final bool wantFirst;

  _Visitor(this.rule, {required this.method, required this.wantFirst});

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!isLifecycleOverride(node, method) ||
        !isInServiceInstanceMember(node)) {
      return;
    }

    final body = node.body;
    final superCall = superCallStatementIn(body, method);
    if (superCall == null || body is! BlockFunctionBody) {
      return;
    }

    final statements = body.block.statements;

    // A lone super call is both the first and the last statement.
    if (statements.length < 2) {
      return;
    }

    final inPosition = wantFirst
        ? statements.first == superCall
        : statements.last == superCall;

    if (inPosition) {
      return;
    }

    rule.reportAtNode(superCall);
  }
}
