import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import '../../util/datahub_types.dart';
import '../../util/naming.dart';

/// Columns the revisable repository of datahub_postgres uses for revision
/// metadata. Mirrors `RevisableLayout.reservedColumns`.
const revisableReservedColumns = {
  'sys_version',
  'sys_creator',
  'sys_created',
  'sys_from',
  'sys_to',
  'sys_is_deleted',
  'sys_head_version',
};

/// Reports a revisable repository whose data class has no usable id.
///
/// Revisions are keyed by the `@Id()` field, which has to be a non-nullable
/// `int` or `String`. Otherwise the repository throws while initializing.
class RevisableBeanRequiresIdRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'revisable_bean_requires_id',
    "'{0}' has no field annotated '@Id()' of type 'int' or 'String', which "
        'revisable repositories require.',
    correctionMessage:
        "Try annotating the non-nullable 'int' or 'String' field identifying "
        "a '{0}' with '@Id()'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.revisable_bean_requires_id',
  );

  RevisableBeanRequiresIdRule()
    : super(
        name: 'revisable_bean_requires_id',
        description:
            'Revisable repositories key revisions by the id field of the data '
            'class, which must be a non-nullable int or String.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _RevisableRepositoryVisitor((node, dataClass) {
      final hasId = _instanceFields(
        dataClass,
      ).any((field) => _isIdField(field) && _isSupportedIdType(field.type));

      if (!hasId) {
        reportAtNode(node, arguments: [dataClass.name ?? 'the data class']);
      }
    });
    registry.addInstanceCreationExpression(this, visitor);
    registry.addClassDeclaration(this, visitor);
  }

  static bool _isIdField(FieldElement field) =>
      field.metadata.annotations.any((annotation) {
        final type = annotation.computeConstantValue()?.type;
        return type is InterfaceType && isClass(type.element, 'Id');
      });

  static bool _isSupportedIdType(DartType type) =>
      (type.isDartCoreInt || type.isDartCoreString) &&
      type.nullabilitySuffix == NullabilitySuffix.none;
}

/// Reports a data class field of a revisable repository whose column name is
/// used for revision metadata.
///
/// The column would be declared twice, so the repository fails to create
/// its tables.
class RevisableReservedColumnRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'revisable_reserved_column',
    "Field '{0}' of '{1}' maps to the column '{2}', which revisable "
        'repositories reserve for revision metadata.',
    correctionMessage: "Try renaming the field '{0}'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.revisable_reserved_column',
  );

  RevisableReservedColumnRule()
    : super(
        name: 'revisable_reserved_column',
        description:
            'Revisable repositories add sys_* columns for revision metadata, '
            'which data class fields must not map to.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _RevisableRepositoryVisitor((node, dataClass) {
      for (final field in _instanceFields(dataClass)) {
        final name = field.name;
        if (name == null) {
          continue;
        }

        final column = lowerSnakeCase(name);
        if (revisableReservedColumns.contains(column)) {
          reportAtNode(
            node,
            arguments: [name, dataClass.name ?? 'the data class', column],
          );
        }
      }
    });
    registry.addInstanceCreationExpression(this, visitor);
    registry.addClassDeclaration(this, visitor);
  }
}

/// Finds revisable repositories and the data class they store:
///
/// * `PostgresqlRevisableRepositoryService(bean: ...)`, reported at the bean
/// * `with PostgresqlRevisableRepository<TService, TData>`, reported at the
///   mixin application
class _RevisableRepositoryVisitor extends SimpleAstVisitor<void> {
  final void Function(AstNode node, InterfaceElement dataClass) onRepository;

  _RevisableRepositoryVisitor(this.onRepository);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isType(
      node.staticType,
      'PostgresqlRevisableRepositoryService',
      package: DatahubPackages.postgres,
    )) {
      return;
    }

    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedArgument || argument.name.lexeme != 'bean') {
        continue;
      }

      final expression = argument.argumentExpression;
      final type = expression.staticType;
      if (isType(type, 'DataBean') && type is InterfaceType) {
        _found(expression, type.typeArguments.singleOrNull);
      }
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    for (final mixin in node.withClause?.mixinTypes ?? const <NamedType>[]) {
      final type = mixin.type;
      if (isType(
            type,
            'PostgresqlRevisableRepository',
            package: DatahubPackages.postgres,
          ) &&
          type is InterfaceType &&
          type.typeArguments.length == 2) {
        _found(mixin, type.typeArguments[1]);
      }
    }
  }

  /// Generic repositories (the data class is a type parameter) and classes
  /// without `@Data()` are not checked.
  void _found(AstNode node, DartType? dataType) {
    if (dataType is! InterfaceType) {
      return;
    }

    final dataClass = dataType.element;
    final isDataClass = dataClass.metadata.annotations.any((annotation) {
      final type = annotation.computeConstantValue()?.type;
      return type is InterfaceType && isClass(type.element, 'Data');
    });

    if (isDataClass) {
      onRepository(node, dataClass);
    }
  }
}

/// Fields stored per instance, excluding those induced by getters / setters.
Iterable<FieldElement> _instanceFields(InterfaceElement element) => element
    .fields
    .where((field) => !field.isStatic && !field.isOriginGetterSetter);
