import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/query_groups.dart';

/// Reports a filter group that can be written shorter.
///
/// Covers `Filter.andGroup([...])`, `Filter.orGroup([...])`, `FilterGroup(...)`
/// and the binary `a.and(b)` / `a.or(b)`. `Filter.reduce()` normalizes all of
/// these at runtime, so the result is the same, but the shorter form is what a
/// reader would have to reconstruct anyway.
///
/// Groups decided by a single operand are left to
/// [ConstantFilterGroupRule], since dropping that operand is no simplification.
class ReducibleFilterGroupRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'reducible_filter_group',
    'This filter group can be written shorter: {0}.',
    correctionMessage: 'Try simplifying the group.',
    severity: DiagnosticSeverity.INFO,
    uniqueName: 'LintCode.reducible_filter_group',
  );

  ReducibleFilterGroupRule()
    : super(
        name: 'reducible_filter_group',
        description:
            'Filter groups that are empty, hold a single filter, nest a group '
            'of the same kind or contain an operand without effect can be '
            'written shorter.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _ReducibleVisitor(this);
    registry.addMethodInvocation(this, visitor);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

/// Reports a filter group that always matches everything or nothing, because
/// one operand decides it: `Filter.empty` in an `or` group, `Filter.nothing`
/// in an `and` group.
///
/// That is rarely what the author meant, so it is a warning without a fix:
/// the other operands are dead and only the author knows whether they or the
/// constant are the mistake.
class ConstantFilterGroupRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'constant_filter_group',
    "This '{0}' group always matches {1}, because it contains '{2}'.",
    correctionMessage: "Try removing '{2}' or replacing the group with it.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.constant_filter_group',
  );

  ConstantFilterGroupRule()
    : super(
        name: 'constant_filter_group',
        description:
            "An 'or' group containing Filter.empty matches everything and an "
            "'and' group containing Filter.nothing matches nothing, whatever "
            'its other operands are.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _ConstantVisitor(this);
    registry.addMethodInvocation(this, visitor);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

/// The operand deciding [group] on its own, if any.
///
/// A group of one operand is equivalent to that operand rather than decided by
/// it, which [ReducibleFilterGroupRule] reports instead.
Expression? _absorbingOperand(QueryGroup group) {
  final operands = group.operands;
  if (operands == null || operands.length < 2) {
    return null;
  }

  return operands.where((o) => isAbsorbingOperand(group.kind, o)).firstOrNull;
}

/// The filter group [node] constructs, if it is one.
QueryGroup? _filterGroupOf(Expression node) {
  final group = queryGroupOf(node);
  return group != null && group.kind != GroupKind.sort ? group : null;
}

class _ReducibleVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _ReducibleVisitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) => _check(node);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      _check(node);

  void _check(Expression node) {
    final group = _filterGroupOf(node);
    if (group == null || _absorbingOperand(group) != null) {
      return;
    }

    final reason = _reason(group);
    if (reason != null) {
      rule.reportAtNode(node, arguments: [reason]);
    }
  }

  String? _reason(QueryGroup group) {
    final operands = group.operands;
    if (operands == null) {
      return null;
    }

    if (operands.isEmpty) {
      return 'it has no filters';
    }

    if (operands.length == 1) {
      return 'it has a single filter';
    }

    final isAnd = group.kind == GroupKind.and;
    for (final operand in operands) {
      if (isNeutralOperand(group.kind, operand)) {
        return isAnd
            ? "'Filter.empty' has no effect in an 'and' group"
            : "'Filter.nothing' has no effect in an 'or' group";
      }

      // `a.and(b).and(c)` is the idiomatic spelling of a flat group.
      if (!group.isBinary && mergeableGroup(group.kind, operand) != null) {
        return "a nested '${group.kind.name}' group can be merged into its "
            'parent';
      }
    }

    return null;
  }
}

class _ConstantVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _ConstantVisitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) => _check(node);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      _check(node);

  void _check(Expression node) {
    final group = _filterGroupOf(node);
    if (group == null) {
      return;
    }

    final operand = _absorbingOperand(group);
    if (operand == null) {
      return;
    }

    final isAnd = group.kind == GroupKind.and;
    rule.reportAtNode(
      operand,
      arguments: [
        group.kind.name,
        isAnd ? 'nothing' : 'everything',
        isAnd ? 'Filter.nothing' : 'Filter.empty',
      ],
    );
  }
}
