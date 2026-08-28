import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import '../../util/datahub_types.dart';
import '../../util/service_instance.dart';

/// Reports `finder.find()` inside a `ServiceInstance`.
///
/// `Find.find` resolves through `Context.ofZone()`, which is the caller's zone
/// and not the service's own position in the component tree.
class PreferInstanceFindRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_instance_find',
    "Resolves the dependency with the caller's zone context.",
    correctionMessage: 'Try using the service instance context: find(finder).',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.prefer_instance_find',
  );

  PreferInstanceFindRule()
    : super(
        name: 'prefer_instance_find',
        description:
            'Inside a ServiceInstance, dependencies should be resolved with '
            'the service instance context via find(finder), not with the '
            "caller's zone context via finder.find().",
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(
      this,
      _AccessorVisitor(this, accessor: 'find', isReceiverType: isFindType),
    );
  }
}

/// Reports `config.read()` inside a `ServiceInstance`.
///
/// `Config.read` resolves through `Context.ofZone()`, which reads config from
/// the caller's scope rather than the service's own config path.
class PreferInstanceReadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_instance_read',
    "Reads the configuration with the caller's zone context.",
    correctionMessage: 'Try using the service instance context: read(config).',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.prefer_instance_read',
  );

  PreferInstanceReadRule()
    : super(
        name: 'prefer_instance_read',
        description:
            'Inside a ServiceInstance, configuration should be read with the '
            'service instance context via read(config), not with the '
            "caller's zone context via config.read().",
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(
      this,
      _AccessorVisitor(this, accessor: 'read', isReceiverType: isConfigType),
    );
  }
}

/// Reports zero-argument `<receiver>.<accessor>()` calls where the receiver is
/// a framework type that resolves through the ambient zone context, and the
/// call sits inside a `ServiceInstance` member.
class _AccessorVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String accessor;
  final bool Function(DartType?) isReceiverType;

  _AccessorVisitor(
    this.rule, {
    required this.accessor,
    required this.isReceiverType,
  });

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != accessor) {
      return;
    }

    final target = node.realTarget;
    if (target == null || node.argumentList.arguments.isNotEmpty) {
      return;
    }

    if (!isReceiverType(target.staticType)) {
      return;
    }

    if (!isInServiceInstanceMember(node)) {
      return;
    }

    rule.reportAtNode(node);
  }
}
