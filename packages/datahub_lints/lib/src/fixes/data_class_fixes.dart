import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../rules/data/data_class_rules.dart';
import '../util/ast.dart';
import '../util/fix_kinds.dart';

/// Inserts the `part '<file>.g.dart';` directive for a `@Data()` library.
class AddPartDirective extends ResolvedCorrectionProducer {
  AddPartDirective({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => DatahubFixKind.addPartDirective;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final unit = node.thisOrAncestorOfType<CompilationUnit>();
    if (unit == null) {
      return;
    }

    final partName = generatedPartName(unit);
    if (partName == null) {
      return;
    }

    // Part directives must follow imports and exports.
    final last = unit.directives
        .where((d) => d is ImportDirective || d is ExportDirective)
        .lastOrNull;

    await builder.addDartFileEdit(file, (builder) {
      if (last != null) {
        builder.addSimpleInsertion(last.end, "\n\npart '$partName';");
      } else {
        builder.addSimpleInsertion(0, "part '$partName';\n\n");
      }
    });
  }
}

/// Adds the generated `$Name` superclass to a `@Data()` class.
class ExtendGeneratedClass extends ResolvedCorrectionProducer {
  ExtendGeneratedClass({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => DatahubFixKind.extendGeneratedClass;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (declaration == null) {
      return;
    }

    final name = classNameToken(declaration);
    final generated = '\$${name.lexeme}';
    final extendsClause = declaration.extendsClause;

    await builder.addDartFileEdit(file, (builder) {
      if (extendsClause == null) {
        builder.addSimpleInsertion(
          declaration.namePart.end,
          ' extends $generated',
        );
      } else {
        builder.addSimpleReplacement(
          range.node(extendsClause.superclass),
          generated,
        );
      }
    });
  }
}

/// Gives a `@Data()` class the unnamed const constructor the generator needs.
///
/// Adds `const` when a suitable constructor already exists, and writes one
/// taking every field as a named parameter when it does not.
class AddDataClassConstructor extends ResolvedCorrectionProducer {
  AddDataClassConstructor({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => DatahubFixKind.addConstKeyword;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (declaration == null || hasPrimaryConstructor(declaration)) {
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

    // Writing a constructor is only safe when none exists at all; otherwise a
    // named one may already be doing the initialization.
    if (hasAnyConstructor(declaration)) {
      return;
    }

    final fields = _instanceFields(declaration);
    final name = classNameToken(declaration).lexeme;

    await builder.addDartFileEdit(file, (builder) {
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

  /// The instance fields of [declaration], paired with whether the generated
  /// parameter must be `required`.
  List<(String, bool)> _instanceFields(ClassDeclaration declaration) => [
    for (final member in classMembers(declaration))
      if (member is FieldDeclaration && !member.isStatic)
        for (final variable in member.fields.variables)
          if (variable.initializer == null)
            (
              variable.name.lexeme,
              _isRequired(variable.declaredFragment?.element.type),
            ),
  ];

  bool _isRequired(DartType? type) =>
      type != null && type.nullabilitySuffix != NullabilitySuffix.question;
}
