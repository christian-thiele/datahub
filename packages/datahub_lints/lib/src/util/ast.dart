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
///
/// Rules that reason about constructors bail out on these rather than guess.
bool hasPrimaryConstructor(ClassDeclaration node) =>
    node.namePart is PrimaryConstructorDeclaration;

/// The unnamed generative constructor declared by [node], if any.
ConstructorDeclaration? unnamedConstructorOf(ClassDeclaration node) =>
    classMembers(node)
        .whereType<ConstructorDeclaration>()
        .where((c) => c.name == null && c.factoryKeyword == null)
        .firstOrNull;

/// Whether [node] declares any constructor at all.
bool hasAnyConstructor(ClassDeclaration node) =>
    classMembers(node).whereType<ConstructorDeclaration>().isNotEmpty;
