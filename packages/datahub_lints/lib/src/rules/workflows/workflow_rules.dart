import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import '../../util/constant_values.dart';
import '../../util/datahub_types.dart';
import '../../util/query_groups.dart';
import '../../util/workflow_steps.dart';

// The rules in this file report what `WorkflowService.validate` throws for
// while the workflow initializes, for the steps of a `WorkflowService` as a
// whole. Only steps passed as a list literal are checked.

/// Reports a `WorkflowService` without steps.
class WorkflowRequiresStepsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'workflow_requires_steps',
    'A workflow needs at least one step.',
    correctionMessage: "Try adding an 'OnEnter' or 'OnSignal' step.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.workflow_requires_steps',
  );

  WorkflowRequiresStepsRule()
    : super(
        name: 'workflow_requires_steps',
        description: 'The steps of a WorkflowService must not be empty.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _WorkflowVisitor((steps) {
        if (isEmptyList(steps)) {
          reportAtNode(steps);
        }
      }),
    );
  }
}

/// Reports steps of a workflow with the same name.
///
/// The name identifies a step in the stored events, so it must be unique.
/// Steps without a `name` get one derived from what triggers them, so this
/// most often means two `OnEnter` steps for the same state and delay.
class DuplicateWorkflowStepNameRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'duplicate_workflow_step_name',
    "There is already a step named '{0}' in this workflow.",
    correctionMessage: "Try giving the step a different 'name'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.duplicate_workflow_step_name',
  );

  DuplicateWorkflowStepNameRule()
    : super(
        name: 'duplicate_workflow_step_name',
        description:
            'The steps of a workflow must have different names, including the '
            'names derived from what triggers them.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _WorkflowVisitor((steps) {
        final names = <String>{};
        for (final step in _stepsOf(steps)) {
          final name = step.name;
          if (name != null && !names.add(name)) {
            reportAtNode(step.reportNode, arguments: [name]);
          }
        }
      }),
    );
  }
}

/// Reports `OnSignal` steps of a workflow for the same signal.
class DuplicateWorkflowSignalRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'duplicate_workflow_signal',
    "There is already a step for the signal '{0}' in this workflow.",
    correctionMessage: "Try handling '{0}' in a single step.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.duplicate_workflow_signal',
  );

  DuplicateWorkflowSignalRule()
    : super(
        name: 'duplicate_workflow_signal',
        description:
            'A workflow can have only one OnSignal step for each type of '
            'signal.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _WorkflowVisitor((steps) {
        final signals = <DartType>{};
        for (final step in _stepsOf(steps).whereType<OnSignalCreation>()) {
          final signal = step.signalType;
          final bean = step.signalBean;
          if (signal is InterfaceType && bean != null && !signals.add(signal)) {
            reportAtNode(bean, arguments: [signal.getDisplayString()]);
          }
        }
      }),
    );
  }
}

/// The steps declared directly in the [steps] list literal.
///
/// Spread, `if` and `for` elements are skipped, so duplicates among those go
/// unnoticed, but nothing is reported wrongly.
Iterable<StepCreation> _stepsOf(Expression steps) {
  final literal = unparenthesized(steps);
  if (literal is! ListLiteral) {
    return const [];
  }
  return literal.elements.whereType<Expression>().map(StepCreation.of).nonNulls;
}

/// Finds the `steps` argument of `WorkflowService(...)`.
class _WorkflowVisitor extends SimpleAstVisitor<void> {
  final void Function(Expression steps) onSteps;

  _WorkflowVisitor(this.onSteps);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isType(node.staticType, 'WorkflowService')) {
      return;
    }

    if (namedArgument(node, 'steps') case final steps?) {
      onSteps(steps);
    }
  }
}
