import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';

import '../util/ast.dart';
import '../util/datahub_types.dart';
import '../util/fix_kinds.dart';
import '../util/lifecycle.dart';

/// Adds a `Find` injection field to a service declaration.
///
/// When the service's `ServiceInstance` is declared in the same file, it also
/// gets a `late final` field for the dependency, resolved in `initialize`.
///
/// The type and the field name are written as linked edit groups, so the
/// editor drops the caret on each in turn the way a snippet would.
class AddFindInjection extends ResolvedCorrectionProducer {
  AddFindInjection({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DatahubAssistKind.addFindInjection;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final declaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (declaration == null || hasPrimaryConstructor(declaration)) {
      return;
    }

    final element = declaration.declaredFragment?.element;
    if (element == null || !isServiceSubtype(element)) {
      return;
    }

    // Without a constructor there is nowhere to thread the parameter through.
    final constructor = unnamedConstructorOf(declaration);
    if (constructor == null) {
      return;
    }

    final members = classMembers(declaration);
    final anchor =
        members.whereType<FieldDeclaration>().lastOrNull?.end ??
        declaration.body.beginToken.end;

    await builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(anchor, (builder) {
        builder.writeln();
        builder.write('  final Find<');
        builder.addSimpleLinkedEdit('type', 'Dependency');
        builder.write('> ');
        builder.addSimpleLinkedEdit('name', 'dependency');
        builder.write(';');
      });

      final parameters = constructor.parameters;
      final (offset, prefix, suffix) = _parameterInsertion(parameters);

      builder.addInsertion(offset, (builder) {
        builder.write(prefix);
        builder.write('this.');
        builder.addSimpleLinkedEdit('name', 'dependency');
        builder.write(' = const Find()');
        builder.write(suffix);
      });

      final instance = _instanceDeclarationOf(element);
      if (instance != null) {
        _addInstanceInjection(builder, instance);
      }
    });
  }

  /// The `ServiceInstance<S>` declared in this file for the service [service].
  ClassDeclaration? _instanceDeclarationOf(InterfaceElement service) {
    for (final declaration in unit.declarations.whereType<ClassDeclaration>()) {
      final element = declaration.declaredFragment?.element;
      if (element == null || hasPrimaryConstructor(declaration)) {
        continue;
      }

      final serviceInstance = element.allSupertypes
          .where((s) => isClass(s.element, 'ServiceInstance'))
          .firstOrNull;

      if (serviceInstance?.typeArguments.firstOrNull?.element == service) {
        return declaration;
      }
    }

    return null;
  }

  /// Adds the `late final` field to [instance] and assigns it in
  /// `initialize`, right after the `super.initialize()` call.
  void _addInstanceInjection(
    DartFileEditBuilder builder,
    ClassDeclaration instance,
  ) {
    final members = classMembers(instance);
    final initialize = members
        .whereType<MethodDeclaration>()
        .where((m) => isLifecycleOverride(m, 'initialize'))
        .firstOrNull;

    // An expression body has no statement list to add the assignment to.
    if (initialize != null && initialize.body is! BlockFunctionBody) {
      return;
    }

    final anchor =
        members.whereType<FieldDeclaration>().lastOrNull?.end ??
        instance.body.beginToken.end;

    builder.addInsertion(anchor, (builder) {
      builder.writeln();
      builder.write('  late final ');
      builder.addSimpleLinkedEdit('type', 'Dependency');
      builder.write(' ');
      builder.addSimpleLinkedEdit('name', 'dependency');
      builder.write(';');
    });

    void writeAssignment(DartEditBuilder builder) {
      builder.write('    ');
      builder.addSimpleLinkedEdit('name', 'dependency');
      builder.write(' = find(service.');
      builder.addSimpleLinkedEdit('name', 'dependency');
      builder.write(');');
    }

    if (initialize == null) {
      final end = members.lastOrNull?.end ?? instance.body.beginToken.end;
      builder.addInsertion(end, (builder) {
        builder.writeln();
        builder.writeln();
        builder.writeln('  @override');
        builder.writeln('  Future<void> initialize() async {');
        builder.writeln('    await super.initialize();');
        writeAssignment(builder);
        builder.writeln();
        builder.write('  }');
      });
      return;
    }

    final body = initialize.body as BlockFunctionBody;
    final offset =
        superCallStatementIn(body, 'initialize')?.end ??
        body.block.leftBracket.end;

    builder.addInsertion(offset, (builder) {
      builder.writeln();
      writeAssignment(builder);
    });
  }

  /// Where to insert the new named parameter, and the punctuation needed
  /// around it.
  ///
  /// A service constructor takes its dependencies as named parameters, so this
  /// opens a `{}` section when the constructor does not have one yet.
  (int, String, String) _parameterInsertion(FormalParameterList parameters) {
    // Existing named section: insert just inside its closing brace.
    if (parameters.rightDelimiter case final delimiter?
        when delimiter.lexeme == '}') {
      final last = parameters.parameters.lastOrNull;
      if (last == null) {
        return (delimiter.offset, '', '');
      }

      // Match the comma style the constructor already uses, so the result
      // does not gain a stray trailing comma.
      final hasTrailingComma = last.endToken.next?.lexeme == ',';

      return hasTrailingComma
          ? (delimiter.offset, '  ', ',\n')
          : (delimiter.offset, ', ', '');
    }

    final last = parameters.parameters.lastOrNull;

    // No parameters at all: open the section inside the parentheses.
    if (last == null) {
      return (parameters.rightParenthesis.offset, '{', '}');
    }

    // Positional parameters only: append a named section after them.
    final next = last.endToken.next;
    final offset = next != null && next.lexeme == ',' ? next.end : last.end;
    final prefix = next != null && next.lexeme == ',' ? ' {' : ', {';

    return (offset, prefix, '}');
  }
}
