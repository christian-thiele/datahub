import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import '../../util/ast.dart';
import '../../util/datahub_types.dart';

/// Reports an `@ApertureRelation<T>()` whose counterpart is missing.
///
/// Aperture resolves a relation by looking for a field on `T` annotated with
/// `@RelationId<Owner>()`. Without it the resource description cannot be built
/// and Aperture throws when the resource is first requested.
class RelationRequiresRelationIdRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'aperture_relation_requires_relation_id',
    "'{0}' declares no field annotated with '@RelationId<{1}>()'.",
    correctionMessage:
        "Try annotating the field on '{0}' that holds the '{1}' id with "
        "'@RelationId<{1}>()'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.aperture_relation_requires_relation_id',
  );

  RelationRequiresRelationIdRule()
    : super(
        name: 'aperture_relation_requires_relation_id',
        description:
            'An ApertureRelation is resolved through a RelationId annotation '
            'on the related data class, which must point back at the '
            'declaring class.',
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
    final owner = node.declaredFragment?.element;
    if (owner == null) {
      return;
    }

    for (final annotation in node.metadata) {
      final related = _apertureRelationTarget(annotation);
      if (related == null) {
        continue;
      }

      if (_hasRelationIdTo(related, owner)) {
        continue;
      }

      rule.reportAtNode(
        annotation,
        arguments: [
          related.name ?? 'the related class',
          classNameToken(node).lexeme,
        ],
      );
    }
  }

  /// The `T` of an `@ApertureRelation<T>()` annotation, if [annotation] is one.
  InterfaceElement? _apertureRelationTarget(Annotation annotation) {
    final element = annotation.name.element;
    if (element == null ||
        element.name != 'ApertureRelation' ||
        !isFromPackage(element, DatahubPackages.aperture)) {
      return null;
    }

    final typeArguments = annotation.typeArguments?.arguments;
    if (typeArguments == null || typeArguments.length != 1) {
      return null;
    }

    final type = typeArguments.single.type;
    return type is InterfaceType ? type.element : null;
  }

  /// Whether [related] has a field annotated `@RelationId<owner>()`.
  bool _hasRelationIdTo(InterfaceElement related, InterfaceElement owner) {
    for (final field in related.fields) {
      for (final annotation in field.metadata.annotations) {
        final type = annotation.computeConstantValue()?.type;
        if (type is! InterfaceType ||
            !isClass(type.element, 'RelationId') ||
            type.typeArguments.length != 1) {
          continue;
        }

        final target = type.typeArguments.single;
        if (target is InterfaceType && target.element == owner) {
          return true;
        }
      }
    }

    return false;
  }
}
