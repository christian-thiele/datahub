import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/ast.dart';
import '../../util/datahub_types.dart';

/// Reports `Service` implementations whose constructor is not `const`.
///
/// A service is a declaration: it holds `Find` and `Config` values that
/// describe the component tree, and by convention is written as a constant.
class ConstServiceConstructorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'const_service_constructor',
    "The Service implementation '{0}' has no const constructor.",
    correctionMessage:
        "Try adding 'const', so that the service declaration can be a "
        'compile-time constant.',
    uniqueName: 'LintCode.const_service_constructor',
  );

  ConstServiceConstructorRule()
    : super(
        name: 'const_service_constructor',
        description:
            'Service implementations are declarations of the component tree '
            'and are conventionally written as constants, which requires a '
            'const constructor.',
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
    final element = node.declaredFragment?.element;
    if (element == null || element.isAbstract || !isServiceSubtype(element)) {
      return;
    }

    // Primary constructors carry their own constness; do not second-guess it.
    if (hasPrimaryConstructor(node)) {
      return;
    }

    final name = classNameToken(node);

    // A class with no explicit constructor gets a non-const default one.
    if (!hasAnyConstructor(node)) {
      rule.reportAtToken(name, arguments: [name.lexeme]);
      return;
    }

    final unnamed = unnamedConstructorOf(node);
    if (unnamed == null || unnamed.constKeyword != null) {
      return;
    }

    final anchor = unnamed.typeName;
    if (anchor != null) {
      rule.reportAtNode(anchor, arguments: [name.lexeme]);
    } else {
      rule.reportAtToken(unnamed.beginToken, arguments: [name.lexeme]);
    }
  }
}
