import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../util/fix_kinds.dart';
import '../util/primary_constructor.dart';

/// Moves the fields of a data class or service into a primary constructor.
class ConvertToPrimaryConstructor extends ResolvedCorrectionProducer {
  ConvertToPrimaryConstructor({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => DatahubFixKind.convertToPrimaryConstructor;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (declaration == null) {
      return;
    }

    final style = primaryConstructorStyleOf(declaration);
    if (style == null) {
      return;
    }

    final conversion = PrimaryConstructorConversion.of(
      declaration,
      isConst: style.isConst,
      inferInjectionTypes: style.inferInjectionTypes,
    );

    if (conversion == null || conversion.constructor == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      conversion.apply(builder, unitResult.content, unit.lineInfo);
    });
  }
}
