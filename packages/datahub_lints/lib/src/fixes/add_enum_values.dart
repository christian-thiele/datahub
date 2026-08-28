import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../util/datahub_types.dart';
import '../util/fix_kinds.dart';

/// Adds the missing `values: MyEnum.values` argument to an enum typed
/// `Config` declaration.
class AddEnumValues extends ResolvedCorrectionProducer {
  AddEnumValues({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => DatahubFixKind.addEnumValues;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final creation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (creation == null) {
      return;
    }

    final enumElement = enumTypeArgumentOf(creation.staticType);
    final enumName = enumElement?.name;
    if (enumName == null) {
      return;
    }

    final arguments = creation.argumentList;
    final existing = arguments.arguments
        .whereType<NamedArgument>()
        .where((a) => a.name.lexeme == 'values')
        .firstOrNull;

    await builder.addDartFileEdit(file, (builder) {
      // Replace an empty `values: []`, otherwise append a new argument.
      if (existing != null) {
        builder.addSimpleReplacement(
          range.node(existing.argumentExpression),
          '$enumName.values',
        );
        return;
      }

      final last = arguments.arguments.lastOrNull;
      if (last == null) {
        builder.addSimpleInsertion(
          arguments.rightParenthesis.offset,
          'values: $enumName.values',
        );
      } else {
        builder.addSimpleInsertion(last.end, ', values: $enumName.values');
      }
    });
  }
}
