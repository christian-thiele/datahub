import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../util/ast.dart';
import '../util/fix_kinds.dart';
import '../util/primary_constructor.dart';

/// Makes a class const-constructible: adds `const` to the primary or unnamed
/// constructor, or declares a const primary constructor when the class relies
/// on the implicit default constructor.
class AddConstKeyword extends ResolvedCorrectionProducer {
  AddConstKeyword({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => DatahubFixKind.addConstKeyword;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (declaration == null) {
      return;
    }

    if (primaryConstructorOf(declaration) case final primary?) {
      if (primary.constKeyword == null) {
        await builder.addDartFileEdit(file, (builder) {
          builder.addSimpleInsertion(primary.typeName.offset, 'const ');
        });
      }
      return;
    }

    final unnamed = unnamedConstructorOf(declaration);

    if (unnamed != null) {
      if (unnamed.constKeyword != null) {
        return;
      }

      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleInsertion(unnamed.offset, 'const ');
      });
      return;
    }

    // No constructor at all: only safe to add one when nothing else is
    // declared that a generated constructor would have to initialize.
    if (hasAnyConstructor(declaration)) {
      return;
    }

    final conversion = PrimaryConstructorConversion.of(
      declaration,
      isConst: true,
      inferInjectionTypes: true,
    );
    if (conversion != null) {
      await builder.addDartFileEdit(file, (builder) {
        conversion.apply(builder, unitResult.content, unit.lineInfo);
      });
      return;
    }

    final name = classNameToken(declaration).lexeme;
    final body = declaration.body;

    await builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(body.beginToken.end, (builder) {
        builder.writeln();
        builder.write('  const $name();');
        builder.writeln();
      });
    });
  }
}
