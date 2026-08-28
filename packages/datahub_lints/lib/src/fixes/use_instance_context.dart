import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../util/datahub_types.dart';
import '../util/fix_kinds.dart';

/// Rewrites zone context lookups into the equivalent instance lookup:
/// `Context.zoneFind(x)` and `Context.ofZone().find(x)` both become `find(x)`.
class UseInstanceContext extends ResolvedCorrectionProducer {
  UseInstanceContext({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => DatahubFixKind.useInstanceFind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final invocation = node.thisOrAncestorOfType<MethodInvocation>();
    if (invocation == null) {
      return;
    }

    final (accessor, argument) = _resolve(invocation) ?? (null, null);
    if (accessor == null || argument == null) {
      return;
    }

    final argumentText = utils.getNodeText(argument);

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        range.node(invocation),
        '$accessor($argumentText)',
      );
    });
  }

  /// Returns the instance accessor and the single argument to forward, for the
  /// zone lookup forms this fix can rewrite.
  (String, Expression)? _resolve(MethodInvocation invocation) {
    final arguments = invocation.argumentList.arguments;
    if (arguments.length != 1) {
      return null;
    }

    final argument = arguments.single.argumentExpression;
    final name = invocation.methodName.name;

    // `Context.zoneFind(x)` / `Context.zoneRead(x)`
    if (const {'zoneFind', 'zoneRead'}.contains(name)) {
      final target = invocation.target;
      if (target is Identifier && isClass(target.element, 'Context')) {
        return (name == 'zoneFind' ? 'find' : 'read', argument);
      }
      return null;
    }

    // `Context.ofZone().find(x)` / `Context.ofZone().read(x)`
    if (const {'find', 'read'}.contains(name)) {
      final target = invocation.realTarget;
      if (target is! MethodInvocation || target.methodName.name != 'ofZone') {
        return null;
      }

      final owner = target.target;
      if (owner is Identifier && isClass(owner.element, 'Context')) {
        return (name, argument);
      }
    }

    return null;
  }
}
