import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';

import '../rules/data/data_class_rules.dart';
import '../util/ast.dart';
import '../util/fix_kinds.dart';

/// Turns a plain class into a DataHub data class.
///
/// Applies every convention the generator relies on at once: the `@Data()`
/// annotation, the generated superclass, the part directive and a const
/// constructor taking the fields as named parameters.
class ConvertToDataClass extends ResolvedCorrectionProducer {
  ConvertToDataClass({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DatahubAssistKind.convertToDataClass;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (declaration == null ||
        hasPrimaryConstructor(declaration) ||
        hasDataAnnotation(declaration)) {
      return;
    }

    // The generated superclass would clash with an existing one.
    if (declaration.extendsClause != null) {
      return;
    }

    final unit = declaration.thisOrAncestorOfType<CompilationUnit>();
    final partName = unit == null ? null : generatedPartName(unit);
    if (unit == null || partName == null) {
      return;
    }

    final name = classNameToken(declaration).lexeme;
    final fields = _namedFields(declaration);
    final constructor = unnamedConstructorOf(declaration);

    // Only safe when there is nothing to reconcile with an existing signature.
    if (constructor != null && constructor.parameters.parameters.isNotEmpty) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      _writePartDirective(builder, unit, partName);

      builder.addSimpleInsertion(declaration.offset, '@Data()\n');
      builder.addSimpleInsertion(declaration.namePart.end, ' extends \$$name');

      if (constructor != null) {
        if (constructor.constKeyword == null) {
          builder.addSimpleInsertion(constructor.offset, 'const ');
        }
        return;
      }

      builder.addInsertion(declaration.body.beginToken.end, (builder) {
        builder.writeln();
        if (fields.isEmpty) {
          builder.writeln('  const $name();');
          return;
        }

        builder.writeln('  const $name({');
        for (final (fieldName, isRequired) in fields) {
          builder.writeln(
            '    ${isRequired ? 'required ' : ''}this.$fieldName,',
          );
        }
        builder.writeln('  });');
      });
    });
  }

  void _writePartDirective(
    DartFileEditBuilder builder,
    CompilationUnit unit,
    String partName,
  ) {
    final alreadyPresent = unit.directives.whereType<PartDirective>().any(
      (d) => d.uri.stringValue == partName,
    );

    if (alreadyPresent) {
      return;
    }

    final last = unit.directives
        .where((d) => d is ImportDirective || d is ExportDirective)
        .lastOrNull;

    if (last != null) {
      builder.addSimpleInsertion(last.end, "\n\npart '$partName';");
    } else {
      builder.addSimpleInsertion(0, "part '$partName';\n\n");
    }
  }

  /// The instance fields, paired with whether the parameter must be required.
  List<(String, bool)> _namedFields(ClassDeclaration declaration) => [
    for (final member in classMembers(declaration))
      if (member is FieldDeclaration && !member.isStatic)
        for (final variable in member.fields.variables)
          if (variable.initializer == null)
            (
              variable.name.lexeme,
              variable.declaredFragment?.element.type.nullabilitySuffix !=
                  NullabilitySuffix.question,
            ),
  ];
}
