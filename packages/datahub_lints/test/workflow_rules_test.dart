import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:datahub_lints/src/rules/workflows/workflow_rules.dart';
import 'package:datahub_lints/src/rules/workflows/workflow_step_rules.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(WorkflowRequiresStepsTest);
    defineReflectiveTests(DuplicateWorkflowStepNameTest);
    defineReflectiveTests(DuplicateWorkflowSignalTest);
    defineReflectiveTests(WorkflowStepNegativeDelayTest);
    defineReflectiveTests(WorkflowStepDelayAndTimeTest);
    defineReflectiveTests(WorkflowStepOwnFailureStateTest);
    defineReflectiveTests(WorkflowSignalRequiresAcceptTest);
    defineReflectiveTests(WorkflowSignalExpiresImmediatelyTest);
    defineReflectiveTests(WorkflowSignalNotForElementTest);
  });
}

/// A workflow of invoices with [steps].
String _source(String steps) =>
    '''
import 'package:datahub/datahub.dart';

class Invoice {}

class Order {}

enum InvoiceState { created, sent, paid, failed }

class Payment implements WorkflowSignal<Invoice> {}

class Shipment implements WorkflowSignal<Order> {}

const paymentBean = DataBean<Payment>();
const shipmentBean = DataBean<Shipment>();

Future<Invoice> handle(Invoice invoice) async => invoice;

Future<Invoice> handleSignal(Invoice invoice, Object signal) async => invoice;

Object target(Object signal) => '';

DateTime? dueDate(Invoice invoice) => null;

final workflow = WorkflowService<Invoice, InvoiceState>(
  steps: [
$steps
  ],
);
''';

/// An `OnSignal` step for [bean] with [arguments].
String _onSignal(String bean, [String arguments = '']) =>
    '    OnSignal($bean, accept: [InvoiceState.sent], target: target, '
    'handle: handleSignal$arguments),';

abstract class _WorkflowRuleTest extends DatahubRuleTest {
  AnalysisRule get workflowRule;

  @override
  void setUp() {
    rule = workflowRule;
    super.setUp();
  }

  /// Expects a diagnostic at the last occurrence of [snippet].
  ExpectedDiagnostic lintOnLast(
    String content,
    String snippet, {
    List<Pattern> message = const [],
  }) => lint(
    content.lastIndexOf(snippet),
    snippet.length,
    messageContainsAll: message,
  );
}

@reflectiveTest
class WorkflowRequiresStepsTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => WorkflowRequiresStepsRule();

  test_steps_areNotReported() async {
    await assertNoDiagnostics(
      _source('    OnEnter(InvoiceState.created, handle),'),
    );
  }

  test_noSteps_isReported() async {
    final content = _source('');
    await assertDiagnostics(content, [lintOnLast(content, '[\n\n  ]')]);
  }
}

@reflectiveTest
class DuplicateWorkflowStepNameTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => DuplicateWorkflowStepNameRule();

  test_differentNames_areNotReported() async {
    await assertNoDiagnostics(
      _source('''
    OnEnter(InvoiceState.created, handle),
    OnEnter(InvoiceState.created, handle, after: Duration(days: 1)),
    OnEnter(InvoiceState.created, handle, at: dueDate),
    OnEnter(InvoiceState.created, handle, name: 'other'),
    OnEnter(InvoiceState.sent, handle),'''),
    );
  }

  test_sameState_isReported() async {
    final content = _source('''
    OnEnter(InvoiceState.created, handle),
    OnEnter(InvoiceState.created, handle),''');
    await assertDiagnostics(content, [
      lintOnLast(content, 'OnEnter', message: ["named 'created'"]),
    ]);
  }

  test_sameDelay_isReported() async {
    final content = _source('''
    OnEnter(InvoiceState.created, handle, after: Duration(hours: 24)),
    OnEnter(InvoiceState.created, handle, after: const Duration(days: 1)),''');
    await assertDiagnostics(content, [
      lintOnLast(
        content,
        'OnEnter',
        message: ["named 'created after 24:00:00.000000'"],
      ),
    ]);
  }

  test_zeroDelay_isReported() async {
    final content = _source('''
    OnEnter(InvoiceState.created, handle),
    OnEnter(InvoiceState.created, handle, after: Duration(seconds: 0)),''');
    await assertDiagnostics(content, [lintOnLast(content, 'OnEnter')]);
  }

  test_sameTime_isReported() async {
    final content = _source('''
    OnEnter(InvoiceState.created, handle, at: dueDate),
    OnEnter(InvoiceState.created, handle, at: (invoice) => null),''');
    await assertDiagnostics(content, [
      lintOnLast(content, 'OnEnter', message: ["named 'created at'"]),
    ]);
  }

  test_explicitName_isReported() async {
    final content = _source('''
    OnEnter(InvoiceState.created, handle),
    ${_onSignal('paymentBean', ", name: 'created'")}''');
    await assertDiagnostics(content, [lintOnLast(content, "'created'")]);
  }

  test_unknownDelay_isNotReported() async {
    await assertNoDiagnostics(
      _source('''
    OnEnter(InvoiceState.created, handle, after: Duration(days: target('').hashCode)),
    OnEnter(InvoiceState.created, handle, after: Duration(days: 1)),'''),
    );
  }
}

@reflectiveTest
class DuplicateWorkflowSignalTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => DuplicateWorkflowSignalRule();

  test_oneStepPerSignal_isNotReported() async {
    await assertNoDiagnostics(_source(_onSignal('paymentBean')));
  }

  test_sameSignal_isReported() async {
    final content = _source('''
${_onSignal('paymentBean')}
${_onSignal('paymentBean', ", name: 'again'")}''');
    await assertDiagnostics(content, [
      lintOnLast(content, 'paymentBean', message: ["signal 'Payment'"]),
    ]);
  }
}

@reflectiveTest
class WorkflowStepNegativeDelayTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => WorkflowStepNegativeDelayRule();

  test_positiveDelay_isNotReported() async {
    await assertNoDiagnostics(
      _source(
        '    OnEnter(InvoiceState.created, handle, after: Duration(days: 1)),',
      ),
    );
  }

  test_negativeDelay_isReported() async {
    final content = _source(
      '    OnEnter(InvoiceState.created, handle, after: Duration(days: -1)),',
    );
    await assertDiagnostics(content, [lintOn(content, 'Duration(days: -1)')]);
  }
}

@reflectiveTest
class WorkflowStepDelayAndTimeTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => WorkflowStepDelayAndTimeRule();

  test_timeOnly_isNotReported() async {
    await assertNoDiagnostics(
      _source('''
    OnEnter(InvoiceState.created, handle, at: dueDate),
    OnEnter(InvoiceState.sent, handle, at: dueDate, after: Duration(days: 0)),
    OnEnter(InvoiceState.paid, handle, at: null, after: Duration(days: 1)),'''),
    );
  }

  test_delayAndTime_isReported() async {
    final content = _source(
      '    OnEnter(InvoiceState.created, handle, at: dueDate, '
      'after: Duration(days: 1)),',
    );
    await assertDiagnostics(content, [lintOn(content, 'Duration(days: 1)')]);
  }
}

@reflectiveTest
class WorkflowStepOwnFailureStateTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => WorkflowStepOwnFailureStateRule();

  test_otherState_isNotReported() async {
    await assertNoDiagnostics(
      _source(
        '    OnEnter(InvoiceState.created, handle, '
        'failureState: InvoiceState.failed),',
      ),
    );
  }

  test_ownState_isReported() async {
    final content = _source(
      '    OnEnter(InvoiceState.created, handle, '
      'failureState: InvoiceState.created),',
    );
    await assertDiagnostics(content, [
      lintOnLast(content, 'InvoiceState.created'),
    ]);
  }

  test_signalStep_isNotReported() async {
    await assertNoDiagnostics(
      _source(_onSignal('paymentBean', ', failureState: InvoiceState.sent')),
    );
  }
}

@reflectiveTest
class WorkflowSignalRequiresAcceptTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => WorkflowSignalRequiresAcceptRule();

  test_accept_isNotReported() async {
    await assertNoDiagnostics(_source(_onSignal('paymentBean')));
  }

  test_noAccept_isReported() async {
    final content = _source(
      '    OnSignal(paymentBean, accept: [], target: target, '
      'handle: handleSignal),',
    );
    await assertDiagnostics(content, [lintOn(content, '[]')]);
  }
}

@reflectiveTest
class WorkflowSignalExpiresImmediatelyTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => WorkflowSignalExpiresImmediatelyRule();

  test_expiry_isNotReported() async {
    await assertNoDiagnostics(
      _source(
        _onSignal('paymentBean', ', expireAfter: Duration(milliseconds: 1)'),
      ),
    );
  }

  test_zeroExpiry_isReported() async {
    final content = _source(
      _onSignal('paymentBean', ', expireAfter: Duration(minutes: 0)'),
    );
    await assertDiagnostics(content, [lintOn(content, 'Duration(minutes: 0)')]);
  }
}

@reflectiveTest
class WorkflowSignalNotForElementTest extends _WorkflowRuleTest {
  @override
  AnalysisRule get workflowRule => WorkflowSignalNotForElementRule();

  test_signalForElement_isNotReported() async {
    await assertNoDiagnostics(_source(_onSignal('paymentBean')));
  }

  test_signalForOtherElement_isReported() async {
    final content = _source(_onSignal('shipmentBean'));
    await assertDiagnostics(content, [
      lintOnLast(
        content,
        'shipmentBean',
        message: ["'Shipment' is not a signal for 'Invoice'"],
      ),
    ]);
  }
}
