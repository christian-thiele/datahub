import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/datahub_types.dart';

/// Reports an enum typed `Config` declared without its possible values.
///
/// Enum configuration is decoded by name, so the declaration is unusable
/// without the list of values and throws a `ConfigDeclarationException` the
/// first time it is read.
class EnumConfigRequiresValuesRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'enum_config_requires_values',
    "Config<{0}> is declared without its possible values.",
    correctionMessage: "Try adding 'values: {0}.values'.",
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.enum_config_requires_values',
  );

  EnumConfigRequiresValuesRule()
    : super(
        name: 'enum_config_requires_values',
        description:
            'Enum typed configuration is decoded by name and cannot be read '
            'without the list of possible values.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Only the path based `Config(...)`; `Config.value(...)` carries its value
    // directly and never decodes.
    if (node.constructorName.name != null) {
      return;
    }

    if (!isConfigType(node.staticType)) {
      return;
    }

    final enumElement = enumTypeArgumentOf(node.staticType);
    if (enumElement == null) {
      return;
    }

    if (_hasNonEmptyValues(node.argumentList)) {
      return;
    }

    rule.reportAtNode(node, arguments: [enumElement.name ?? 'Enum']);
  }

  /// Whether the argument list passes a `values:` argument that is not an
  /// empty list literal.
  bool _hasNonEmptyValues(ArgumentList arguments) {
    for (final argument in arguments.arguments) {
      if (argument is! NamedArgument || argument.name.lexeme != 'values') {
        continue;
      }

      final expression = argument.argumentExpression;
      if (expression is ListLiteral && expression.elements.isEmpty) {
        return false;
      }

      return true;
    }

    return false;
  }
}
