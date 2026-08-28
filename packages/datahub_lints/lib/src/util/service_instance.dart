import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import 'datahub_types.dart';

/// Returns the declaration of the class or mixin enclosing [node], or `null`
/// when [node] is not inside one.
Declaration? enclosingTypeDeclaration(AstNode node) {
  for (AstNode? current = node; current != null; current = current.parent) {
    if (current is ClassDeclaration || current is MixinDeclaration) {
      return current as Declaration;
    }
  }

  return null;
}

/// Whether [node] sits inside a member of a `ServiceInstance` subtype.
///
/// For a mixin this checks the `on` clause, so mixins applied to a
/// `ServiceInstance` (as `PostgresqlDataRepository` is) count as well.
///
/// This is the scoping guard for the injection rules. Outside a
/// `ServiceInstance` there is no instance context to prefer, so
/// `finder.find()` and `config.read()` are the correct form there.
bool isInServiceInstanceMember(AstNode node) {
  final declaration = enclosingTypeDeclaration(node);

  return switch (declaration) {
    ClassDeclaration(:final declaredFragment) => isServiceInstanceSubtype(
      declaredFragment?.element,
    ),
    MixinDeclaration(:final declaredFragment) =>
      declaredFragment?.element.superclassConstraints.any(
            (c) => isServiceInstanceSubtype(c.element),
          ) ??
          false,
    _ => false,
  };
}

/// The `InterfaceElement` for the class declaration enclosing [node], if any.
InterfaceElement? enclosingInterfaceElement(AstNode node) =>
    switch (enclosingTypeDeclaration(node)) {
      ClassDeclaration(:final declaredFragment) => declaredFragment?.element,
      MixinDeclaration(:final declaredFragment) => declaredFragment?.element,
      _ => null,
    };
