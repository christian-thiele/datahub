import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';

import '../util/ast.dart';
import '../util/datahub_types.dart';
import '../util/fix_kinds.dart';

/// Writes the `ServiceInstance` half of a service.
///
/// Every service in the framework is this same pair: a const declaration
/// holding `Find` and `Config` values, and an instance class that does the
/// work. This generates the missing half.
class GenerateServiceInstance extends ResolvedCorrectionProducer {
  GenerateServiceInstance({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DatahubAssistKind.generateServiceInstance;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (declaration == null) {
      return;
    }

    final element = declaration.declaredFragment?.element;
    if (element == null || element.isAbstract || !isServiceSubtype(element)) {
      return;
    }

    // Only offer this where the pair is actually missing.
    final hasCreateInstance = classMembers(declaration)
        .whereType<MethodDeclaration>()
        .any((m) => m.name.lexeme == 'createInstance');

    if (hasCreateInstance) {
      return;
    }

    final serviceName = classNameToken(declaration).lexeme;
    final instanceName = '${serviceName}Instance';
    await builder.addDartFileEdit(file, (builder) {
      final anchor =
          classMembers(declaration).lastOrNull?.end ??
          declaration.body.beginToken.end;

      builder.addInsertion(anchor, (builder) {
        builder.writeln();
        builder.writeln();
        builder.writeln('  @override');
        builder.write('  ServiceInstance<$serviceName> createInstance() =>');
        builder.write(' $instanceName();');
      });

      // Anchored to the declaration rather than the end of the unit, so the
      // result does not depend on whether the file ends with a newline.
      builder.addInsertion(declaration.end, (builder) {
        builder.writeln();
        builder.writeln();
        builder.writeln(
          'class $instanceName extends ServiceInstance<$serviceName> {',
        );
        builder.writeln('  @override');
        builder.writeln('  Future<void> initialize() async {');
        builder.writeln('    await super.initialize();');
        builder.writeln('  }');
        builder.write('}');
      });
    });
  }
}
