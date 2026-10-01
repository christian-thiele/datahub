import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/query_groups.dart';

/// Reports a sort group that can be written shorter.
///
/// Covers `Sort.followedBy([...])` and `SortGroup([...])`. Sort keys are order
/// sensitive, so only redundancy that keeps the key order is reported.
class ReducibleSortGroupRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'reducible_sort_group',
    'This sort group can be written shorter: {0}.',
    correctionMessage: 'Try simplifying the group.',
    severity: DiagnosticSeverity.INFO,
    uniqueName: 'LintCode.reducible_sort_group',
  );

  ReducibleSortGroupRule()
    : super(
        name: 'reducible_sort_group',
        description:
            'Sort groups that are empty, hold a single sort, nest another '
            'group or contain Sort.empty can be written shorter.',
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
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) => _check(node);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      _check(node);

  void _check(Expression node) {
    final group = queryGroupOf(node);
    if (group == null || group.kind != GroupKind.sort) {
      return;
    }

    final reason = _reason(group.operands);
    if (reason != null) {
      rule.reportAtNode(node, arguments: [reason]);
    }
  }

  String? _reason(List<Expression>? operands) {
    if (operands == null) {
      return null;
    }

    if (operands.isEmpty) {
      return 'it has no sorts';
    }

    if (operands.length == 1) {
      return 'it has a single sort';
    }

    for (final operand in operands) {
      if (isEmptySort(operand)) {
        return "'Sort.empty' has no effect in a group";
      }

      if (mergeableGroup(GroupKind.sort, operand) != null) {
        return 'a nested group can be merged into its parent';
      }
    }

    return null;
  }
}
