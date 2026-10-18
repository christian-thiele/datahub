import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// The token holding the declared name of [node].
///
/// Analyzer 14 moved this behind [ClassDeclaration.namePart], which also
/// covers primary constructors.
Token classNameToken(ClassDeclaration node) => node.namePart.typeName;

/// The members declared in the body of [node].
NodeList<ClassMember> classMembers(ClassDeclaration node) => node.body.members;

/// Whether [node] declares a primary constructor.
bool hasPrimaryConstructor(ClassDeclaration node) =>
    node.namePart is PrimaryConstructorDeclaration;

/// Whether the library containing [node] can declare primary constructors.
///
/// They need language version 3.13, so libraries on an older version keep
/// getting the classic constructor.
bool supportsPrimaryConstructors(AstNode node) =>
    node.thisOrAncestorOfType<CompilationUnit>()?.featureSet.isEnabled(
      Feature.primary_constructors,
    ) ??
    false;

/// The primary constructor declared by [node], if any.
PrimaryConstructorDeclaration? primaryConstructorOf(ClassDeclaration node) =>
    switch (node.namePart) {
      final PrimaryConstructorDeclaration primary => primary,
      _ => null,
    };

/// The unnamed generative constructor declared by [node], if any.
ConstructorDeclaration? unnamedConstructorOf(ClassDeclaration node) =>
    classMembers(node)
        .whereType<ConstructorDeclaration>()
        .where((c) => c.name == null && c.factoryKeyword == null)
        .firstOrNull;

/// Whether [node] declares any constructor at all.
bool hasAnyConstructor(ClassDeclaration node) =>
    classMembers(node).whereType<ConstructorDeclaration>().isNotEmpty;
