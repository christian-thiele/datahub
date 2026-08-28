import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../util/fix_kinds.dart';
import '../util/lifecycle.dart';

/// Moves `super.initialize()` to the top of the override.
class MoveSuperInitializeFirst extends _MoveLifecycleSuper {
  MoveSuperInitializeFirst({required super.context});

  @override
  String get method => 'initialize';

  @override
  bool get toFront => true;

  @override
  FixKind get fixKind => DatahubFixKind.moveSuperInitializeFirst;
}

/// Moves `super.dispose()` to the bottom of the override.
class MoveSuperDisposeLast extends _MoveLifecycleSuper {
  MoveSuperDisposeLast({required super.context});

  @override
  String get method => 'dispose';

  @override
  bool get toFront => false;

  @override
  FixKind get fixKind => DatahubFixKind.moveSuperDisposeLast;
}

abstract class _MoveLifecycleSuper extends ResolvedCorrectionProducer {
  _MoveLifecycleSuper({required super.context});

  /// The lifecycle method whose super call is being moved.
  String get method;

  /// Whether the call moves to the first position; otherwise the last.
  bool get toFront;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<MethodDeclaration>();
    if (declaration == null || !isLifecycleOverride(declaration, method)) {
      return;
    }

    final body = declaration.body;
    final superCall = superCallStatementIn(body, method);
    if (superCall == null || body is! BlockFunctionBody) {
      return;
    }

    final statements = body.block.statements;
    if (statements.length < 2) {
      return;
    }

    final anchor = toFront ? statements.first : statements.last;
    if (anchor == superCall) {
      return;
    }

    // Move whole lines, so the statement keeps its indentation and does not
    // get merged onto a neighbouring line.
    final source = utils.getLinesRange(range.node(superCall));
    final text = utils.getRangeText(source);
    final target = utils.getLinesRange(range.node(anchor));

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(source);
      builder.addSimpleInsertion(toFront ? target.offset : target.end, text);
    });
  }
}
