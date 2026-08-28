import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:path/path.dart' as p;

import '../../util/ast.dart';
import '../../util/datahub_types.dart';

/// Whether [node] carries the `@Data()` annotation from `package:datahub`.
bool hasDataAnnotation(ClassDeclaration node) => node.metadata.any((a) {
  final element = a.name.element;
  return isClass(element, 'Data') ||
      (element != null &&
          element.name == 'Data' &&
          isFromPackage(element, DatahubPackages.datahub));
});

/// The name of the generated part file for [unit]'s source.
String? generatedPartName(CompilationUnit unit) {
  final path = unit.declaredFragment?.source.uri.pathSegments.lastOrNull;
  if (path == null || !path.endsWith('.dart')) {
    return null;
  }

  return '${p.basenameWithoutExtension(path)}.g.dart';
}

/// Reports a `@Data()` class in a library without its generated part.
///
/// The builder emits into `<file>.g.dart`; without the directive the
/// generated superclass never becomes visible.
class DataClassRequiresPartRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'data_class_requires_part',
    "Missing the generated part directive for '{0}'.",
    correctionMessage: "Try adding \"part '{0}';\".",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.data_class_requires_part',
  );

  DataClassRequiresPartRule()
    : super(
        name: 'data_class_requires_part',
        description:
            'A library declaring @Data() classes must include the generated '
            'part file, otherwise the generated code is never visible.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _PartVisitor(this));
  }
}

class _PartVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _PartVisitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasDataAnnotation(node)) {
      return;
    }

    final unit = node.thisOrAncestorOfType<CompilationUnit>();
    if (unit == null) {
      return;
    }

    final expected = generatedPartName(unit);
    if (expected == null) {
      return;
    }

    final hasPart = unit.directives.whereType<PartDirective>().any(
      (d) => d.uri.stringValue == expected,
    );

    if (hasPart) {
      return;
    }

    rule.reportAtToken(classNameToken(node), arguments: [expected]);
  }
}

/// Reports a `@Data()` class that does not extend its generated superclass.
class DataClassExtendsGeneratedRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'data_class_extends_generated',
    "The data class '{0}' does not extend '\${0}'.",
    correctionMessage: "Try adding 'extends \${0}'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.data_class_extends_generated',
  );

  DataClassExtendsGeneratedRule()
    : super(
        name: 'data_class_extends_generated',
        description:
            'A @Data() class gets its fields, codec and bean from a generated '
            r'$-prefixed superclass, which it must extend.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _ExtendsVisitor(this));
  }
}

class _ExtendsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _ExtendsVisitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasDataAnnotation(node)) {
      return;
    }

    final name = classNameToken(node);
    final expected = '\$${name.lexeme}';

    if (node.extendsClause?.superclass.name.lexeme == expected) {
      return;
    }

    rule.reportAtToken(name, arguments: [name.lexeme]);
  }
}

/// Reports a `@Data()` class whose constructor the generator cannot use.
///
/// The builder looks up the unnamed const constructor and reads only its
/// named field-formal parameters.
class DataClassConstConstructorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'data_class_const_constructor',
    "The data class '{0}' needs an unnamed const constructor with named "
        'parameters.',
    correctionMessage:
        'Try declaring a const constructor that takes all fields as named '
        'parameters.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.data_class_const_constructor',
  );

  DataClassConstConstructorRule()
    : super(
        name: 'data_class_const_constructor',
        description:
            'The data builder resolves the unnamed const constructor of a '
            '@Data() class and reads only its named field-formal parameters.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _ConstructorVisitor(this));
  }
}

class _ConstructorVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _ConstructorVisitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasDataAnnotation(node) || hasPrimaryConstructor(node)) {
      return;
    }

    final name = classNameToken(node);
    final unnamed = unnamedConstructorOf(node);

    if (unnamed == null || unnamed.constKeyword == null) {
      rule.reportAtToken(name, arguments: [name.lexeme]);
      return;
    }

    // Positional parameters are invisible to the generator, so a class that
    // uses them silently loses those fields.
    final positional = unnamed.parameters.parameters
        .where((p) => p.isPositional)
        .toList();

    if (positional.isNotEmpty) {
      rule.reportAtNode(positional.first, arguments: [name.lexeme]);
    }
  }
}
