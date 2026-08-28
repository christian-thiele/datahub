import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/datahub_types.dart';
import '../../util/defaults_yaml.dart';

/// Reports a `Config` that has neither an in-code default nor an entry in the
/// package's `resources/defaults.yaml`.
///
/// A declaration with no default and no documented entry throws
/// `ConfigPathException` on first read unless the deployment happens to set
/// it, and nothing tells the reader that the knob exists.
///
/// The path is checked exactly as written. `Config` paths are relative to the
/// enclosing `Scope`, so the absolute path a value ends up at depends on where
/// the service is mounted in `buildRoot()` — which is why the defaults file is
/// per package and keyed the same way the declaration is.
class ConfigRequiresDefaultRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'config_requires_default',
    "'{0}' has no default and no entry in resources/defaults.yaml.",
    correctionMessage:
        "Try adding a 'defaultValue' argument, or an entry for '{0}' in "
        'resources/defaults.yaml.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.config_requires_default',
  );

  ConfigRequiresDefaultRule()
    : super(
        name: 'config_requires_default',
        description:
            'Configuration without an in-code default should be listed in the '
            "package's resources/defaults.yaml, so that every knob a package "
            'reads has one place it is written down.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // Tests build their configuration programmatically — the integration test
    // host, for one, generates `test.services.<name>.<containerPort>` entries
    // at run time — so defaults.yaml says nothing about them.
    if (context.isInTestDirectory) {
      return;
    }

    // A package without the file opts out, so do not even walk the AST.
    final defaults = defaultsFileFor(context.definingUnit.file);
    if (defaults == null) {
      return;
    }

    registry.addInstanceCreationExpression(this, _Visitor(this, defaults));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final DefaultsFile defaults;

  _Visitor(this.rule, this.defaults);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // `Config.value(...)` carries its value directly and reads nothing.
    if (node.constructorName.name != null) {
      return;
    }

    if (!isConfigType(node.staticType)) {
      return;
    }

    final arguments = node.argumentList.arguments;

    // An in-code default already fully specifies the declaration.
    final hasDefault = arguments.any(
      (a) => a is NamedArgument && a.name.lexeme == 'defaultValue',
    );

    if (hasDefault) {
      return;
    }

    // The path is the single positional argument. A positional argument is
    // itself the expression; a named one is not, which is what distinguishes
    // them here.
    final first = arguments.firstOrNull;
    if (first is! Expression) {
      return;
    }

    // Only a literal path can be checked; anything computed is left alone.
    if (first is! SimpleStringLiteral || defaults.declares(first.value)) {
      return;
    }

    rule.reportAtNode(node, arguments: [first.value]);
  }
}
