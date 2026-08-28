import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../util/fix_kinds.dart';

/// Rewrites `finder.find()` into `find(finder)`.
class UseInstanceFind extends _UseInstanceAccessor {
  UseInstanceFind({required super.context});

  @override
  String get accessor => 'find';

  @override
  FixKind get fixKind => DatahubFixKind.useInstanceFind;
}

/// Rewrites `config.read()` into `read(config)`.
class UseInstanceRead extends _UseInstanceAccessor {
  UseInstanceRead({required super.context});

  @override
  String get accessor => 'read';

  @override
  FixKind get fixKind => DatahubFixKind.useInstanceRead;
}

abstract class _UseInstanceAccessor extends ResolvedCorrectionProducer {
  _UseInstanceAccessor({required super.context});

  /// The `ServiceInstance` method to route the call through.
  String get accessor;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final invocation = node.thisOrAncestorOfType<MethodInvocation>();
    if (invocation == null || invocation.methodName.name != accessor) {
      return;
    }

    final target = invocation.realTarget;
    if (target == null || invocation.argumentList.arguments.isNotEmpty) {
      return;
    }

    // A cascade has no receiver expression to move into the argument list.
    if (invocation.isCascaded) {
      return;
    }

    final receiver = utils.getNodeText(target);

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        range.node(invocation),
        '$accessor($receiver)',
      );
    });
  }
}
