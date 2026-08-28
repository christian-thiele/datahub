import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../util/fix_kinds.dart';

/// Inserts the missing `await` before an unawaited lifecycle super call.
class AddAwait extends ResolvedCorrectionProducer {
  AddAwait({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => DatahubFixKind.addAwait;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final invocation = node.thisOrAncestorOfType<MethodInvocation>();
    if (invocation == null || invocation.parent is! ExpressionStatement) {
      return;
    }

    // Only meaningful in an async body; a sync override cannot await.
    final body = invocation.thisOrAncestorOfType<FunctionBody>();
    if (body == null || !body.isAsynchronous) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(invocation.offset, 'await ');
    });
  }
}
