import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/error/error.dart';

import '../../util/constant_values.dart';
import '../../util/datahub_types.dart';
import '../../util/workflow_steps.dart';

// The rules in this file report what `WorkflowService.validate` throws for
// while the workflow initializes, for each step on its own. They check steps
// wherever they are declared, not only inside a `WorkflowService`.

/// Reports an `OnEnter` step with a negative delay.
class WorkflowStepNegativeDelayRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'workflow_step_negative_delay',
    'The delay of a workflow step must not be negative.',
    correctionMessage: 'Try a delay of Duration.zero or more.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.workflow_step_negative_delay',
  );

  WorkflowStepNegativeDelayRule()
    : super(
        name: 'workflow_step_negative_delay',
        description:
            "The 'after' delay of an OnEnter step must not be negative.",
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
      _StepVisitor((step) {
        if (step is OnEnterCreation &&
            step.after != null &&
            (step.delay?.isNegative ?? false)) {
          reportAtNode(step.after);
        }
      }),
    );
  }
}

/// Reports an `OnEnter` step with both a delay and a time.
class WorkflowStepDelayAndTimeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'workflow_step_delay_and_time',
    "A workflow step can not run both 'after' a delay and 'at' a time.",
    correctionMessage: "Try removing either 'after' or 'at'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.workflow_step_delay_and_time',
  );

  WorkflowStepDelayAndTimeRule()
    : super(
        name: 'workflow_step_delay_and_time',
        description:
            "An OnEnter step runs either after a delay or at a time taken from "
            'the element, not both.',
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
      _StepVisitor((step) {
        // A delay that can not be evaluated may still be zero.
        if (step is OnEnterCreation &&
            step.hasTime == true &&
            step.delay != null &&
            step.delay != Duration.zero) {
          reportAtNode(step.after);
        }
      }),
    );
  }
}

/// Reports an `OnEnter` step whose failure state is the state it runs in.
///
/// A failed element would enter the state again and the step would run again,
/// endlessly.
class WorkflowStepOwnFailureStateRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'workflow_step_own_failure_state',
    'The failure state of a workflow step must not be the state it runs in.',
    correctionMessage:
        "Try another 'failureState', or none to park the failed event.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.workflow_step_own_failure_state',
  );

  WorkflowStepOwnFailureStateRule()
    : super(
        name: 'workflow_step_own_failure_state',
        description:
            'An OnEnter step that fails must not move the element back into '
            'the state the step runs in.',
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
      _StepVisitor((step) {
        if (step is! OnEnterCreation) {
          return;
        }

        final state = step.state;
        final failureState = step.failureState;
        if (state == null || failureState == null) {
          return;
        }

        final stateValue = constantValueOf(state);
        if (stateValue != null && stateValue == constantValueOf(failureState)) {
          reportAtNode(failureState);
        }
      }),
    );
  }
}

/// Reports an `OnSignal` step that accepts its signal in no state.
class WorkflowSignalRequiresAcceptRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'workflow_signal_requires_accept',
    'This step accepts its signal in no state, so it never runs.',
    correctionMessage:
        "Try adding the states in which the signal is applied to 'accept'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.workflow_signal_requires_accept',
  );

  WorkflowSignalRequiresAcceptRule()
    : super(
        name: 'workflow_signal_requires_accept',
        description:
            "The 'accept' states of an OnSignal step must not be empty.",
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
      _StepVisitor((step) {
        if (step is OnSignalCreation) {
          final accept = step.accept;
          if (accept != null && isEmptyList(accept)) {
            reportAtNode(accept);
          }
        }
      }),
    );
  }
}

/// Reports an `OnSignal` step whose signals expire immediately.
class WorkflowSignalExpiresImmediatelyRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'workflow_signal_expires_immediately',
    'The signals of this step expire immediately.',
    correctionMessage: "Try an 'expireAfter' greater than Duration.zero.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.workflow_signal_expires_immediately',
  );

  WorkflowSignalExpiresImmediatelyRule()
    : super(
        name: 'workflow_signal_expires_immediately',
        description:
            "The 'expireAfter' of an OnSignal step must be greater than zero.",
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
      _StepVisitor((step) {
        if (step is! OnSignalCreation) {
          return;
        }

        final expireAfter = step.expireAfter;
        final value = expireAfter == null ? null : durationValueOf(expireAfter);
        if (expireAfter != null && value != null && value <= Duration.zero) {
          reportAtNode(expireAfter);
        }
      }),
    );
  }
}

/// Reports an `OnSignal` step whose signal does not implement
/// `WorkflowSignal<T>` for the element type `T` of the workflow.
///
/// `Workflow<T>.send` only takes a `WorkflowSignal<T>`, so the step could
/// never run.
class WorkflowSignalNotForElementRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'workflow_signal_not_for_element',
    "'{0}' is not a signal for '{1}', so it can never be sent to this "
        'workflow.',
    correctionMessage: "Try letting '{0}' implement 'WorkflowSignal<{1}>'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.workflow_signal_not_for_element',
  );

  WorkflowSignalNotForElementRule()
    : super(
        name: 'workflow_signal_not_for_element',
        description:
            'The signal of an OnSignal step must implement WorkflowSignal for '
            'the element type of the workflow.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final typeSystem = context.typeSystem;
    registry.addInstanceCreationExpression(
      this,
      _StepVisitor((step) {
        if (step is! OnSignalCreation) {
          return;
        }

        final element = step.elementType;
        final signal = step.signalType;
        final bean = step.signalBean;
        // Without a concrete element type (no WorkflowService to infer it
        // from) any signal would do.
        if (bean == null ||
            element is! InterfaceType ||
            isClass(element.element, 'DataObject') ||
            signal is! InterfaceType) {
          return;
        }

        if (!_isSignalFor(signal, element, typeSystem)) {
          reportAtNode(
            bean,
            arguments: [signal.getDisplayString(), element.getDisplayString()],
          );
        }
      }),
    );
  }

  /// Mirrors `OnSignal.isSignalForElement`.
  static bool _isSignalFor(
    InterfaceType signal,
    InterfaceType element,
    TypeSystem typeSystem,
  ) => [signal, ...signal.allSupertypes].any(
    (type) =>
        isClass(type.element, 'WorkflowSignal') &&
        type.typeArguments.length == 1 &&
        typeSystem.isSubtypeOf(type.typeArguments.single, element),
  );
}

class _StepVisitor extends SimpleAstVisitor<void> {
  final void Function(StepCreation step) onStep;

  _StepVisitor(this.onStep);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (StepCreation.of(node) case final step?) {
      onStep(step);
    }
  }
}
