import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

import '../../util/datahub_types.dart';

/// Postgres mixins that assign `late final` state in `initialize()`.
const _statefulMixins = {
  'PostgresqlDataRepository',
  'DatabaseConnectionManager',
};

/// Reports an `initialize()` override that never calls `super.initialize()`
/// while mixing in a postgres repository.
///
/// Those mixins build their relation and connection pool in `initialize()`, so
/// skipping the super call leaves `late final` fields unassigned and fails
/// later, far from the cause.
class RepositoryRequiresSuperInitializeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'postgres_repository_requires_super_initialize',
    "'initialize()' does not call 'super.initialize()'.",
    correctionMessage:
        "Try adding 'await super.initialize();', which sets up the relation "
        'and the connection pool.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.postgres_repository_requires_super_initialize',
  );

  RepositoryRequiresSuperInitializeRule()
    : super(
        name: 'postgres_repository_requires_super_initialize',
        description:
            'The postgres repository mixins assign late final state in '
            'initialize(). An override that does not call the super method '
            'leaves that state unassigned.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme != 'initialize' || node.isStatic) {
      return;
    }

    final body = node.body;
    if (body is EmptyFunctionBody) {
      return;
    }

    // Analyzer 14 nests members under a ClassBody rather than directly under
    // the declaration.
    final owner = node.thisOrAncestorOfType<ClassDeclaration>();
    final element = owner?.declaredFragment?.element;
    if (element == null || !_usesStatefulMixin(element)) {
      return;
    }

    if (_callsSuperInitialize(body)) {
      return;
    }

    rule.reportAtToken(node.name);
  }

  bool _usesStatefulMixin(InterfaceElement element) =>
      element.allSupertypes.any(
        (s) =>
            _statefulMixins.contains(s.element.name) &&
            isFromPackage(s.element, DatahubPackages.postgres),
      );

  bool _callsSuperInitialize(FunctionBody body) {
    final finder = _SuperInitializeFinder();
    body.accept(finder);
    return finder.found;
  }
}

/// Walks a method body looking for any `super.initialize()` call.
class _SuperInitializeFinder extends RecursiveAstVisitor<void> {
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target is SuperExpression &&
        node.methodName.name == 'initialize') {
      found = true;
    }
    super.visitMethodInvocation(node);
  }
}
