import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import 'datahub_types.dart';

/// The expression without any enclosing parentheses.
Expression unparenthesized(Expression expression) {
  var current = expression;
  while (current is ParenthesizedExpression) {
    current = current.expression;
  }
  return current;
}

/// Whether [element] is a member declared by the datahub class [className].
bool isMemberOf(Element? element, String className) =>
    isClass(element?.enclosingElement, className);

/// Whether [expression] reads the static `Filter.empty`-style member [member]
/// of [className], or constructs [constructor] directly.
bool isSingleton(
  Expression expression, {
  required String className,
  required String member,
  required String constructor,
}) {
  switch (unparenthesized(expression)) {
    case PrefixedIdentifier(:final identifier):
      return identifier.name == member &&
          isMemberOf(identifier.element, className);
    case PropertyAccess(:final propertyName):
      return propertyName.name == member &&
          isMemberOf(propertyName.element, className);
    case InstanceCreationExpression(:final constructorName):
      return isClass(constructorName.element?.enclosingElement, constructor);
    default:
      return false;
  }
}

/// The plain elements of a list literal argument, or `null` if [expression] is
/// not a list literal or contains spreads, `if` or `for` elements, whose
/// length cannot be known statically.
List<Expression>? plainElements(Expression? expression) {
  if (expression == null) {
    return null;
  }

  final literal = unparenthesized(expression);
  if (literal is! ListLiteral) {
    return null;
  }

  final elements = literal.elements;
  if (!elements.every((e) => e is Expression)) {
    return null;
  }

  return elements.cast<Expression>().toList(growable: false);
}

/// The arguments of [list] if every one is a plain expression.
///
/// Named arguments are not [Expression]s in recent analyzer versions, so the
/// callers, whose signatures only take positional parameters, bail out on them.
List<Expression>? expressionArguments(ArgumentList list) {
  final arguments = list.arguments;
  if (!arguments.every((a) => a is Expression)) {
    return null;
  }

  return arguments.cast<Expression>().toList(growable: false);
}

/// What a [QueryGroup] combines its operands into.
enum GroupKind {
  /// A conjunction of filters: `Filter.andGroup`, `FilterGroup(…, true)` or
  /// `a.and(b)`.
  and,

  /// A disjunction of filters: `Filter.orGroup`, `FilterGroup(…, false)` or
  /// `a.or(b)`.
  or,

  /// A sequence of sort keys: `Sort.followedBy` or `SortGroup`.
  sort,
}

/// A filter or sort group spelled out in source.
final class QueryGroup {
  /// The expression constructing the group.
  final Expression node;

  final GroupKind kind;

  /// The operands in source order, or `null` when they cannot be known
  /// statically (see [plainElements]).
  final List<Expression>? operands;

  /// The list literal holding [operands], `null` for a binary `a.and(b)`.
  final ListLiteral? list;

  /// The `Filter` or `Sort` class, for writing references to its constants.
  final InterfaceElement? baseClass;

  const QueryGroup._(
    this.node,
    this.kind,
    this.operands, {
    this.list,
    this.baseClass,
  });

  /// Whether this is a binary `a.and(b)` / `a.or(b)` call.
  bool get isBinary => list == null;
}

/// The group [expression] constructs, if it is one.
QueryGroup? queryGroupOf(Expression expression) {
  switch (expression) {
    case MethodInvocation(:final methodName, :final argumentList):
      final element = methodName.element;
      final owner = element?.enclosingElement;
      final args = expressionArguments(argumentList);
      if (args == null || args.length != 1 || owner is! InterfaceElement) {
        return null;
      }

      final kind = switch (methodName.name) {
        'andGroup' || 'and' when isClass(owner, 'Filter') => GroupKind.and,
        'orGroup' || 'or' when isClass(owner, 'Filter') => GroupKind.or,
        'followedBy' when isClass(owner, 'Sort') => GroupKind.sort,
        _ => null,
      };
      if (kind == null) {
        return null;
      }

      if (methodName.name case 'and' || 'or') {
        final target = expression.realTarget;
        if (target == null) {
          return null;
        }
        return QueryGroup._(expression, kind, [
          target,
          args.single,
        ], baseClass: owner);
      }

      final list = unparenthesized(args.single);
      return QueryGroup._(
        expression,
        kind,
        plainElements(list),
        list: list is ListLiteral ? list : null,
        baseClass: owner,
      );

    case InstanceCreationExpression(
      :final constructorName,
      :final argumentList,
    ):
      final owner = constructorName.element?.enclosingElement;
      final args = expressionArguments(argumentList);
      if (owner is! InterfaceElement || args == null) {
        return null;
      }

      final GroupKind kind;
      if (isClass(owner, 'FilterGroup') && args.length == 2) {
        final polarity = unparenthesized(args[1]);
        if (polarity is! BooleanLiteral) {
          return null;
        }
        kind = polarity.value ? GroupKind.and : GroupKind.or;
      } else if (isClass(owner, 'SortGroup') && args.length == 1) {
        kind = GroupKind.sort;
      } else {
        return null;
      }

      final list = unparenthesized(args.first);
      return QueryGroup._(
        expression,
        kind,
        plainElements(list),
        list: list is ListLiteral ? list : null,
        baseClass: owner.supertype?.element,
      );

    default:
      return null;
  }
}

/// Whether [operand] has no effect in a group of [kind]: `Filter.empty` in an
/// `and`, `Filter.nothing` in an `or`, `Sort.empty` in a sort.
bool isNeutralOperand(GroupKind kind, Expression operand) => switch (kind) {
  GroupKind.and => isEmptyFilter(operand),
  GroupKind.or => isNothingFilter(operand),
  GroupKind.sort => isEmptySort(operand),
};

/// Whether [operand] decides a group of [kind] on its own: `Filter.nothing` in
/// an `and`, `Filter.empty` in an `or`.
bool isAbsorbingOperand(GroupKind kind, Expression operand) => switch (kind) {
  GroupKind.and => isNothingFilter(operand),
  GroupKind.or => isEmptyFilter(operand),
  GroupKind.sort => false,
};

bool isEmptyFilter(Expression e) => isSingleton(
  e,
  className: 'Filter',
  member: 'empty',
  constructor: 'EmptyFilter',
);

bool isNothingFilter(Expression e) => isSingleton(
  e,
  className: 'Filter',
  member: 'nothing',
  constructor: 'NothingFilter',
);

bool isEmptySort(Expression e) => isSingleton(
  e,
  className: 'Sort',
  member: 'empty',
  constructor: 'EmptySort',
);

/// The group of the same [kind] that [operand] constructs, if its operands are
/// known and it can therefore be merged into its parent.
QueryGroup? mergeableGroup(GroupKind kind, Expression operand) {
  final group = queryGroupOf(unparenthesized(operand));
  return group != null && group.kind == kind && group.operands != null
      ? group
      : null;
}

/// The operands [group] keeps once neutral operands are dropped and nested
/// groups of the same kind are merged into it.
final class GroupReduction {
  /// The remaining operands, in source order.
  final List<Expression> operands;

  /// The first neutral operand dropped, which is what a group of only neutral
  /// operands is equivalent to.
  final Expression? neutral;

  const GroupReduction._(this.operands, this.neutral);

  /// Reduces [group], whose operands must be known.
  ///
  /// [mergeNested] merges nested groups of the same kind, at any depth. Their
  /// own neutral operands are dropped as well, absorbing ones are kept.
  factory GroupReduction.of(QueryGroup group, {bool mergeNested = true}) {
    final operands = <Expression>[];
    Expression? neutral;

    void collect(List<Expression> source) {
      for (final operand in source) {
        if (isNeutralOperand(group.kind, operand)) {
          neutral ??= operand;
          continue;
        }

        final nested = mergeNested ? mergeableGroup(group.kind, operand) : null;
        if (nested != null) {
          collect(nested.operands!);
        } else {
          operands.add(unparenthesized(operand));
        }
      }
    }

    collect(group.operands!);
    return GroupReduction._(operands, neutral);
  }
}
