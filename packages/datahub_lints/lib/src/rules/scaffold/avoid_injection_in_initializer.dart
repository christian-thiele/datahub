import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/service_instance.dart';

/// `ServiceInstance` members that the service host assigns after construction.
const _lateMembers = {'context', 'registry', 'service'};

/// Members that read through the (not yet assigned) context.
const _injectionMembers = {'find', 'read'};

/// Reports dependency injection in a `ServiceInstance` constructor.
///
/// `context`, `registry` and `service` are `late final` and are assigned by
/// the service host only after `createInstance()` returns, so a constructor
/// that touches them throws a `LateInitializationError`.
///
/// Non-late *field* initializers are not reported: referencing an instance
/// member there is already a compile-time error
/// (`implicit_this_reference_in_initializer`), and repeating it would just add
/// noise on top of the error the user has to fix anyway.
class AvoidInjectionInInitializerRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_injection_in_initializer',
    'Uses the service instance context before it is assigned.',
    correctionMessage:
        'Try moving this into initialize(), which runs once the service host '
        'has assigned the context.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.avoid_injection_in_initializer',
  );

  AvoidInjectionInInitializerRule()
    : super(
        name: 'avoid_injection_in_initializer',
        description:
            'The context of a ServiceInstance is assigned after '
            'createInstance() returns, so a constructor cannot resolve '
            'dependencies or read configuration.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
    registry.addSimpleIdentifier(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!_injectionMembers.contains(node.methodName.name)) {
      return;
    }

    // Only unqualified calls reach the instance's own find/read.
    final target = node.realTarget;
    if (target != null && target is! ThisExpression) {
      return;
    }

    if (_isInConstructor(node)) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!_lateMembers.contains(node.name) || node.inDeclarationContext()) {
      return;
    }

    // Skip identifiers that merely happen to share the name but are qualified
    // by some other receiver, or are a method name rather than a reference.
    final parent = node.parent;
    if (parent is PropertyAccess && parent.propertyName != node) {
      return;
    }
    if (parent is PrefixedIdentifier && parent.identifier != node) {
      return;
    }
    if (parent is MethodInvocation && parent.methodName == node) {
      return;
    }

    if (_isInConstructor(node)) {
      rule.reportAtNode(node);
    }
  }

  /// Whether [node] runs as part of constructing the instance.
  ///
  /// A closure defers evaluation past construction, so anything inside one is
  /// left alone.
  bool _isInConstructor(AstNode node) {
    if (!isInServiceInstanceMember(node)) {
      return false;
    }

    for (AstNode? current = node; current != null; current = current.parent) {
      if (current is FunctionExpression) {
        return false;
      }

      if (current is ConstructorDeclaration) {
        return true;
      }

      if (current is MethodDeclaration || current is ClassDeclaration) {
        return false;
      }
    }

    return false;
  }
}
