import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/datahub_types.dart';
import '../../util/service_instance.dart';

/// The `Context` statics that reach for the ambient zone context.
const _zoneAccessors = {'ofZone', 'maybeOfZone', 'zoneFind', 'zoneRead'};

/// Reports uses of the zone context inside a `ServiceInstance`.
///
/// A `ServiceInstance` owns a `context` that is scoped to its position in the
/// component tree. Reaching for `Context.ofZone()` instead resolves against
/// whatever zone happens to be current at the call site.
class AvoidZoneContextInServiceRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_zone_context_in_service',
    "Uses the zone context inside a ServiceInstance.",
    correctionMessage:
        'Try using the service instance context via find(), read() or the '
        'context field.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.avoid_zone_context_in_service',
  );

  AvoidZoneContextInServiceRule()
    : super(
        name: 'avoid_zone_context_in_service',
        description:
            'A ServiceInstance has its own context, scoped to its position in '
            'the component tree. Reaching for the zone context inside one '
            'resolves against the caller instead.',
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
    if (!_zoneAccessors.contains(node.methodName.name)) {
      return;
    }

    // `Context.ofZone()` and friends are static, so the target is the class.
    final target = node.target;
    if (target is! Identifier || !isClass(target.element, 'Context')) {
      return;
    }

    if (!isInServiceInstanceMember(node)) {
      return;
    }

    // Report the whole `Context.ofZone().find(x)` chain when there is one, so
    // that the fix has the full expression to replace.
    final parent = node.parent;
    if (parent is MethodInvocation &&
        parent.realTarget == node &&
        const {'find', 'read'}.contains(parent.methodName.name)) {
      rule.reportAtNode(parent);
      return;
    }

    rule.reportAtNode(node);
  }
}
