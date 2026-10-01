import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import '../../util/datahub_types.dart';

/// Reports an `ApertureResource` whose `@ApertureRelation<R>()` has no
/// resource for `R` in the same `ApertureApi`.
///
/// Aperture builds a relation from the beans of all registered resources, and
/// throws "Related bean for R not found for ApertureRelation of T" when the
/// resource description is first requested.
class RelationRequiresResourceRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'aperture_relation_requires_resource',
    "'{0}' declares an '@ApertureRelation<{1}>()', but no 'ApertureResource' "
        "for '{1}' is registered in this 'ApertureApi'.",
    correctionMessage:
        "Try adding an 'ApertureResource' for '{1}' to 'resources', or "
        "removing the relation from '{0}'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.aperture_relation_requires_resource',
  );

  RelationRequiresResourceRule()
    : super(
        name: 'aperture_relation_requires_resource',
        description:
            'The related class of an ApertureRelation must be registered as an '
            'ApertureResource in the same ApertureApi.',
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
    if (!isClass(
      node.constructorName.type.element,
      'ApertureApi',
      package: DatahubPackages.aperture,
    )) {
      return;
    }

    final resources = _resourcesArgument(node);
    if (resources == null) {
      return;
    }

    // Resources that cannot be resolved statically (spreads, variables, other
    // constructors) may provide any bean, so the rule gives up entirely.
    final registered = <InterfaceElement>{};
    final entries = <(InstanceCreationExpression, InterfaceElement)>[];
    for (final element in resources.elements) {
      if (element is! InstanceCreationExpression) {
        return;
      }

      final bean = _resourceBean(element);
      if (bean == null) {
        return;
      }

      registered.add(bean);
      entries.add((element, bean));
    }

    for (final (creation, bean) in entries) {
      for (final annotation in bean.metadata.annotations) {
        final related = _relationTarget(annotation);
        if (related == null || registered.contains(related)) {
          continue;
        }

        rule.reportAtNode(
          creation,
          arguments: [bean.name ?? 'the resource', related.name ?? 'the class'],
        );
      }
    }
  }

  ListLiteral? _resourcesArgument(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedArgument && argument.name.lexeme == 'resources') {
        final value = argument.argumentExpression;
        return value is ListLiteral ? value : null;
      }
    }

    return null;
  }

  /// The `T` of `ApertureResource(repository: Find<DataRepository<T>>())`.
  InterfaceElement? _resourceBean(InstanceCreationExpression node) {
    if (!isClass(
      node.constructorName.type.element,
      'ApertureResource',
      package: DatahubPackages.aperture,
    )) {
      return null;
    }

    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedArgument || argument.name.lexeme != 'repository') {
        continue;
      }

      final find = argument.argumentExpression.staticType;
      if (find is! InterfaceType ||
          !isClass(find.element, 'Find') ||
          find.typeArguments.length != 1) {
        return null;
      }

      final repository = find.typeArguments.single;
      if (repository is! InterfaceType) {
        return null;
      }

      for (final type in [repository, ...repository.element.allSupertypes]) {
        if (isClass(type.element, 'DataRepository') &&
            type.typeArguments.length == 1) {
          final bean = type.typeArguments.single;
          return bean is InterfaceType ? bean.element : null;
        }
      }
    }

    return null;
  }

  /// The `R` of an `@ApertureRelation<R>()` annotation, if [annotation] is one.
  InterfaceElement? _relationTarget(ElementAnnotation annotation) {
    final type = annotation.computeConstantValue()?.type;
    if (type is! InterfaceType ||
        !isClass(
          type.element,
          'ApertureRelation',
          package: DatahubPackages.aperture,
        ) ||
        type.typeArguments.length != 1) {
      return null;
    }

    final target = type.typeArguments.single;
    return target is InterfaceType ? target.element : null;
  }
}
