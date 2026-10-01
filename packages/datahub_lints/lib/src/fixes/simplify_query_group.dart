import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/precedence.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../util/fix_kinds.dart';
import '../util/query_groups.dart';

/// Rewrites a filter or sort group reported as reducible into its shortest
/// form: an empty group becomes `empty`, a single operand replaces the group,
/// neutral operands are dropped and nested groups of the same kind merged.
///
/// Operands that decide the group on their own are never dropped; those are
/// reported by `constant_filter_group`, which has no fix.
class SimplifyQueryGroup extends ResolvedCorrectionProducer {
  SimplifyQueryGroup({required super.context});

  @override
  CorrectionApplicability get applicability =>
      // Nested groups are reported individually, and fixing the outer one
      // rewrites the inner ones, so the edits cannot be batched.
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => DatahubFixKind.simplifyQueryGroup;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final group = _reportedGroup();
    if (group == null || group.operands == null) {
      return;
    }

    // `a.and(b).and(c)` is not reported, so neither is it merged here.
    final reduction = GroupReduction.of(group, mergeNested: !group.isBinary);
    final operands = reduction.operands;

    if (operands.isEmpty) {
      final neutral = reduction.neutral;
      final baseClass = group.baseClass;
      await builder.addDartFileEdit(file, (builder) {
        builder.addReplacement(range.node(group.node), (builder) {
          if (neutral != null) {
            // Spelled the way the author wrote it, which keeps any prefix.
            builder.write(_source(neutral));
          } else if (baseClass != null) {
            builder.writeReference(baseClass);
            builder.write('.empty');
          }
        });
      });
      return;
    }

    if (operands.length == 1) {
      final single = operands.single;
      final text = _needsParentheses(group.node, single)
          ? '(${_source(single)})'
          : _source(single);
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(group.node), text);
      });
      return;
    }

    final list = group.list;
    if (list == null) {
      return;
    }

    final trailingComma = list.rightBracket.previous?.lexeme == ',' ? ',' : '';
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        range.endStart(list.leftBracket, list.rightBracket),
        operands.map(_source).join(', ') + trailingComma,
      );
    });
  }

  /// The innermost group enclosing the diagnostic.
  QueryGroup? _reportedGroup() {
    for (AstNode? current = node; current != null; current = current.parent) {
      if (current is Expression) {
        final group = queryGroupOf(current);
        if (group != null) {
          return group;
        }
      }
    }
    return null;
  }

  String _source(AstNode node) =>
      unitResult.content.substring(node.offset, node.end);

  /// Whether [replacement] has to be parenthesized to take the place of
  /// [node], which is a call and therefore binds tighter than most operators.
  bool _needsParentheses(Expression node, Expression replacement) {
    if (replacement.precedence >= Precedence.postfix) {
      return false;
    }

    return switch (node.parent) {
      ArgumentList() ||
      ListLiteral() ||
      NamedArgument() ||
      ParenthesizedExpression() ||
      VariableDeclaration() ||
      ReturnStatement() ||
      ExpressionStatement() ||
      ExpressionFunctionBody() => false,
      AssignmentExpression(:final rightHandSide) => rightHandSide != node,
      _ => true,
    };
  }
}
