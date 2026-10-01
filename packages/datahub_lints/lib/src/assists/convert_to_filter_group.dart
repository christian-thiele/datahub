import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../util/fix_kinds.dart';
import '../util/query_groups.dart';

/// Converts a chain of `a.and(b).and(c)` into `Filter.andGroup([a, b, c])`,
/// and likewise for `or`.
///
/// Chains are idiomatic and not reported, so this is an assist rather than a
/// fix. It merges only binary calls; operands are otherwise kept as written.
class ConvertToFilterGroup extends ResolvedCorrectionProducer {
  ConvertToFilterGroup({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DatahubAssistKind.convertToFilterGroup;

  @override
  List<String>? get assistArguments => _arguments;

  List<String>? _arguments;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var chain = _enclosingBinaryGroup(node);
    if (chain == null) {
      return;
    }

    // Climb to the outermost call of the chain, `x` in `x = a.and(b).and(c)`.
    while (true) {
      final parent = chain!.node.parent;
      if (parent is! MethodInvocation || parent.realTarget != chain.node) {
        break;
      }

      final outer = queryGroupOf(parent);
      if (outer == null || !outer.isBinary || outer.kind != chain.kind) {
        break;
      }
      chain = outer;
    }

    final baseClass = chain.baseClass;
    if (baseClass == null) {
      return;
    }

    final operands = <Expression>[];
    void collect(Expression operand) {
      final nested = queryGroupOf(unparenthesized(operand));
      if (nested != null && nested.isBinary && nested.kind == chain!.kind) {
        nested.operands!.forEach(collect);
      } else {
        operands.add(unparenthesized(operand));
      }
    }

    chain.operands!.forEach(collect);

    final method = '${chain.kind.name}Group';
    _arguments = [method];

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(chain!.node), (builder) {
        builder.writeReference(baseClass);
        builder.write('.$method([');
        builder.write(operands.map(_source).join(', '));
        builder.write('])');
      });
    });
  }

  /// The innermost `a.and(b)` / `a.or(b)` call enclosing [node].
  QueryGroup? _enclosingBinaryGroup(AstNode node) {
    for (AstNode? current = node; current != null; current = current.parent) {
      if (current is MethodInvocation) {
        final group = queryGroupOf(current);
        if (group != null && group.isBinary) {
          return group;
        }
      }
    }
    return null;
  }

  String _source(AstNode node) =>
      unitResult.content.substring(node.offset, node.end);
}
