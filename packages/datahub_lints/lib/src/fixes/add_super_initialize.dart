import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../util/fix_kinds.dart';

/// Inserts the missing `await super.initialize();` at the top of an override.
class AddSuperInitialize extends ResolvedCorrectionProducer {
  AddSuperInitialize({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => DatahubFixKind.addSuperInitialize;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final method = node.thisOrAncestorOfType<MethodDeclaration>();
    if (method == null || method.name.lexeme != 'initialize') {
      return;
    }

    final body = method.body;
    if (body is! BlockFunctionBody) {
      return;
    }

    // The mixins set up state the override then builds on, so the super call
    // belongs first.
    final call = body.isAsynchronous
        ? 'await super.initialize();'
        : 'super.initialize();';

    await builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(body.block.leftBracket.end, (builder) {
        builder.writeln();
        builder.write('    $call');
      });
    });
  }
}
