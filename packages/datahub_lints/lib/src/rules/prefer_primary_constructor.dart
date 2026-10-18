import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../util/ast.dart';
import '../util/primary_constructor.dart';

/// Reports a data class or service that declares its fields in the body and
/// initializes them through a separate constructor.
///
/// Both are written with a primary constructor by convention, which declares
/// each field once:
///
/// ```dart
/// @Data()
/// class const Person({required final String name}) extends $Person;
///
/// class const MyService({
///   final dependency = const Find<Dependency>(),
///   final host = const Config<String>('host'),
/// }) implements Service { ... }
/// ```
///
/// Only classes the quick fix can convert mechanically are reported.
class PreferPrimaryConstructorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_primary_constructor',
    "'{0}' can declare its fields in a primary constructor.",
    correctionMessage:
        'Try converting the constructor into a primary constructor.',
    uniqueName: 'LintCode.prefer_primary_constructor',
  );

  PreferPrimaryConstructorRule()
    : super(
        name: 'prefer_primary_constructor',
        description:
            'Data classes and services declare their fields as parameters of '
            'a primary constructor, instead of repeating each field in a '
            'separate constructor.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final style = primaryConstructorStyleOf(node);
    if (style == null) {
      return;
    }

    final conversion = PrimaryConstructorConversion.of(
      node,
      isConst: style.isConst,
      inferInjectionTypes: style.inferInjectionTypes,
    );

    // A class relying on the implicit constructor has nothing to convert;
    // the const constructor rules cover those.
    final constructor = conversion?.constructor;
    if (constructor == null) {
      return;
    }

    final name = classNameToken(node);
    rule.reportAtNode(
      constructor.typeName ?? constructor,
      arguments: [name.lexeme],
    );
  }
}
