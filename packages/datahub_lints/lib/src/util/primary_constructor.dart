import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../rules/data/data_class_rules.dart';
import 'ast.dart';
import 'datahub_types.dart';

/// How the classes DataHub generates or injects into declare their primary
/// constructor.
typedef PrimaryConstructorStyle = ({bool isConst, bool inferInjectionTypes});

/// The primary constructor convention [node] follows, or `null` when it is
/// neither a data class nor a service.
///
/// Data classes are always const, since the generator requires it. Services
/// declare their `Find` and `Config` dependencies without a type annotation,
/// letting the type follow from the default value:
///
/// ```dart
/// class const MyService({
///   final dependency = const Find<Dependency>(),
///   final host = const Config<String>('host'),
/// }) implements Service { ... }
/// ```
PrimaryConstructorStyle? primaryConstructorStyleOf(ClassDeclaration node) {
  if (hasDataAnnotation(node)) {
    return (isConst: true, inferInjectionTypes: false);
  }

  final element = node.declaredFragment?.element;
  if (element != null && !element.isAbstract && isServiceSubtype(element)) {
    final constructor = PrimaryConstructorConversion._convertibleConstructor(
      node,
    );
    return (
      isConst: constructor?.constKeyword != null,
      inferInjectionTypes: true,
    );
  }

  return null;
}

/// An instance field of a class body that becomes a declaring parameter.
final class _Field {
  final FieldDeclaration declaration;
  final VariableDeclaration variable;

  _Field(this.declaration, this.variable);

  String get name => variable.name.lexeme;

  DartType? get type => variable.declaredFragment?.element.type;

  bool get isNullable =>
      type == null ||
      type is DynamicType ||
      type?.nullabilitySuffix == NullabilitySuffix.question;
}

/// Rewrites a class declaring its fields in the body into one declaring them
/// as parameters of a primary constructor.
///
/// The constructor (if any) and the field declarations it initializes are
/// removed. When nothing else is left in the body, the body is dropped as
/// well:
///
/// ```dart
/// class const Person({required final String name}) extends $Person;
/// ```
final class PrimaryConstructorConversion {
  final ClassDeclaration declaration;

  /// The constructor that is replaced, or `null` when the class relies on the
  /// implicit default constructor.
  final ConstructorDeclaration? constructor;

  /// Whether the primary constructor is const.
  final bool isConst;

  /// Whether `Find` / `Config` parameters drop their type annotation in
  /// favour of type arguments on their default value.
  final bool inferInjectionTypes;

  /// The field formal parameters of [constructor] and the field each
  /// initializes.
  final Map<FieldFormalParameter, _Field> _parameters;

  /// The fields that become named parameters when there is no [constructor].
  final List<_Field> _fields;

  PrimaryConstructorConversion._(
    this.declaration, {
    required this.constructor,
    required this.isConst,
    required this.inferInjectionTypes,
    required this._parameters,
    required this._fields,
  });

  /// Plans the conversion of [declaration], or returns `null` when it cannot
  /// be converted mechanically.
  ///
  /// A class without a constructor gets one taking every uninitialized field
  /// as a named parameter, required unless the field is nullable. A class
  /// with a single non-redirecting generative constructor is converted when
  /// that constructor only initializes fields through `this.` parameters.
  ///
  /// Returns `null` as well when the library's language version predates
  /// primary constructors.
  ///
  /// [isConst] defaults to the constness of the existing constructor.
  static PrimaryConstructorConversion? of(
    ClassDeclaration declaration, {
    bool? isConst,
    bool inferInjectionTypes = false,
  }) {
    if (hasPrimaryConstructor(declaration) ||
        !supportsPrimaryConstructors(declaration)) {
      return null;
    }

    final fields = _instanceFields(declaration);
    final uninitialized = [
      for (final field in fields.values)
        if (field.variable.initializer == null) field,
    ];

    final generative = classMembers(declaration)
        .whereType<ConstructorDeclaration>()
        .where((c) => c.factoryKeyword == null)
        .toList();

    if (generative.isEmpty) {
      if (!_coversWholeDeclarations(uninitialized)) {
        return null;
      }

      return PrimaryConstructorConversion._(
        declaration,
        constructor: null,
        isConst: isConst ?? false,
        inferInjectionTypes: inferInjectionTypes,
        parameters: const {},
        fields: uninitialized,
      );
    }

    final constructor = _convertibleConstructor(declaration);
    if (constructor == null) {
      return null;
    }

    final parameters = <FieldFormalParameter, _Field>{};
    for (final parameter in constructor.parameters.parameters) {
      if (parameter is! FieldFormalParameter) {
        // `super.` and plain parameters are allowed in a primary constructor
        // as they are, so they are carried over unchanged.
        continue;
      }

      final field = fields[parameter.name.lexeme];
      if (field == null ||
          field.variable.initializer != null ||
          parameter.functionTypedSuffix != null) {
        return null;
      }

      parameters[parameter] = field;
    }

    // A field the constructor does not initialize would be left without a
    // value, and a declaration only partly moved cannot be removed.
    final covered = parameters.values.toSet();
    if (uninitialized.any((f) => !covered.contains(f)) ||
        !_coversWholeDeclarations(covered)) {
      return null;
    }

    return PrimaryConstructorConversion._(
      declaration,
      constructor: constructor,
      isConst: isConst ?? constructor.constKeyword != null,
      inferInjectionTypes: inferInjectionTypes,
      parameters: parameters,
      fields: const [],
    );
  }

  /// The only non-redirecting generative constructor of [declaration], when
  /// it does nothing but initialize fields through its parameters.
  static ConstructorDeclaration? _convertibleConstructor(
    ClassDeclaration declaration,
  ) {
    final generative = classMembers(declaration)
        .whereType<ConstructorDeclaration>()
        .where((c) => c.factoryKeyword == null)
        .where(
          (c) =>
              !c.initializers.any((i) => i is RedirectingConstructorInvocation),
        )
        .toList();

    if (generative.length != 1) {
      return null;
    }

    final constructor = generative.single;
    final isConvertible =
        constructor.externalKeyword == null &&
        constructor.augmentKeyword == null &&
        constructor.body is EmptyFunctionBody &&
        constructor.initializers.isEmpty &&
        constructor.documentationComment == null &&
        constructor.metadata.isEmpty;

    return isConvertible ? constructor : null;
  }

  /// The instance fields of [declaration] that a declaring parameter can
  /// express, by name.
  static Map<String, _Field> _instanceFields(ClassDeclaration declaration) {
    final fields = <String, _Field>{};
    for (final member in classMembers(declaration)) {
      if (member is! FieldDeclaration || member.isStatic) {
        continue;
      }

      // These stay in the body; a declaring parameter cannot express them.
      if (member.fields.isLate ||
          member.externalKeyword != null ||
          member.abstractKeyword != null) {
        continue;
      }

      for (final variable in member.fields.variables) {
        fields[variable.name.lexeme] = _Field(member, variable);
      }
    }

    return fields;
  }

  /// Whether [fields] contains every variable of each declaration it touches.
  static bool _coversWholeDeclarations(Iterable<_Field> fields) {
    final names = {for (final f in fields) f.variable};
    return fields.every(
      (f) => f.declaration.fields.variables.every(names.contains),
    );
  }

  /// The field declarations removed from the body.
  Set<FieldDeclaration> get _removedFields => {
    for (final field in _parameters.values) field.declaration,
    for (final field in _fields) field.declaration,
  };

  /// Writes the conversion.
  ///
  /// [clauses] is inserted right after the parameter list, so that callers
  /// can add a superclass in the same edit.
  void apply(
    DartFileEditBuilder builder,
    String content,
    LineInfo lineInfo, {
    String clauses = '',
  }) {
    final namePart = declaration.namePart;
    final name = switch (constructor?.name) {
      final name? => '.${name.lexeme}',
      null => '',
    };
    final header = '$name${_parameterList(content, lineInfo)}$clauses';

    if (isConst) {
      builder.addSimpleInsertion(namePart.typeName.offset, 'const ');
    }

    final removed = <ClassMember>[..._removedFields, ?constructor];
    final body = declaration.body;

    if (body is BlockClassBody && _leavesBodyEmpty(content, body, removed)) {
      final clausesBefore = content
          .substring(namePart.end, body.leftBracket.offset)
          .trimRight();
      builder.addSimpleReplacement(
        range.startOffsetEndOffset(namePart.end, body.end),
        '$header$clausesBefore;',
      );
      return;
    }

    builder.addSimpleInsertion(namePart.end, header);

    if (body is BlockClassBody) {
      for (final deletion in _deletions(content, lineInfo, body, removed)) {
        builder.addDeletion(deletion);
      }
    }
  }

  /// The source of the new formal parameter list, including parentheses.
  String _parameterList(String content, LineInfo lineInfo) {
    if (constructor case final constructor?) {
      final list = constructor.parameters;
      var source = content.substring(list.offset, list.end);

      // Replace back to front, so that earlier offsets stay valid.
      final parameters = _parameters.entries.toList()
        ..sort((a, b) => b.key.offset.compareTo(a.key.offset));

      for (final MapEntry(key: parameter, value: field) in parameters) {
        final replacement = _declaringParameter(
          content,
          field,
          parameter: parameter,
          isRequired: parameter.requiredKeyword != null,
          indent: _indentOf(content, lineInfo, parameter.offset),
        );
        source = source.replaceRange(
          parameter.offset - list.offset,
          parameter.end - list.offset,
          replacement,
        );
      }

      // The parameters move from the constructor up into the class header,
      // so lose one level of indentation. Multiline strings keep theirs.
      final indent = _indentOf(content, lineInfo, constructor.offset);
      if (indent.isEmpty || source.contains("'''") || source.contains('"""')) {
        return source;
      }

      final lines = source.split('\n');
      return [
        lines.first,
        for (final line in lines.skip(1))
          line.startsWith(indent) ? line.substring(indent.length) : line,
      ].join('\n');
    }

    if (_fields.isEmpty) {
      return '()';
    }

    final multiline = _fields.any(
      (f) => f.declaration.documentationComment != null,
    );

    final parameters = [
      for (final field in _fields)
        _declaringParameter(
          content,
          field,
          isRequired: !field.isNullable,
          indent: multiline ? '  ' : '',
        ),
    ];

    if (multiline) {
      return '({\n${parameters.map((p) => '  $p,\n').join()}})';
    }

    return '({${parameters.join(', ')}})';
  }

  /// The source of the declaring parameter for [field].
  String _declaringParameter(
    String content,
    _Field field, {
    FieldFormalParameter? parameter,
    required bool isRequired,
    required String indent,
  }) {
    String source(AstNode node) => content.substring(node.offset, node.end);

    final buffer = StringBuffer();

    if (field.declaration.documentationComment case final comment?) {
      buffer.write('${source(comment)}\n$indent');
    }

    for (final annotation in [
      ...field.declaration.metadata,
      ...?parameter?.metadata,
    ]) {
      buffer.write('${source(annotation)} ');
    }

    if (isRequired && (parameter == null || parameter.isNamed)) {
      buffer.write('required ');
    }

    final isFinal = isConst || field.declaration.fields.isFinal;
    buffer.write(isFinal ? 'final ' : 'var ');

    final defaultValue = parameter?.defaultClause?.value;
    final injection = _injectionDefault(content, field, defaultValue);

    if (injection == null) {
      final type = parameter?.type ?? field.declaration.fields.type;
      if (type != null) {
        buffer.write('${source(type)} ');
      }
    }

    buffer.write(field.name);

    if (injection != null) {
      buffer.write(' = $injection');
    } else if (defaultValue != null) {
      buffer.write(' = ${source(defaultValue)}');
    }

    return buffer.toString();
  }

  /// The default value of a `Find` / `Config` parameter written so that it
  /// carries the type of [field] by itself, or `null` when the parameter
  /// keeps its type annotation.
  String? _injectionDefault(String content, _Field field, Expression? value) {
    final type = field.type;
    if (!inferInjectionTypes ||
        type is! InterfaceType ||
        !(isFindType(type) || isConfigType(type)) ||
        value is! InstanceCreationExpression ||
        value.staticType != type) {
      return null;
    }

    final source = content.substring(value.offset, value.end);
    final createdType = value.constructorName.type;
    if (createdType.typeArguments != null || type.typeArguments.isEmpty) {
      return source;
    }

    // Without the field's type as context, the type arguments would no
    // longer be inferred, so spell them out.
    final annotation = field.declaration.fields.type;
    final arguments = switch (annotation) {
      NamedType(:final typeArguments?) => content.substring(
        typeArguments.offset,
        typeArguments.end,
      ),
      _ =>
        '<${type.typeArguments.map((t) => t.getDisplayString()).join(', ')}>',
    };

    final at = createdType.end - value.offset;
    return source.replaceRange(at, at, arguments);
  }

  /// Whether removing [removed] leaves nothing but whitespace in [body].
  static bool _leavesBodyEmpty(
    String content,
    BlockClassBody body,
    List<ClassMember> removed,
  ) {
    if (!body.members.every(removed.contains)) {
      return false;
    }

    // Comments that do not belong to a member would be lost.
    var rest = content.substring(
      body.leftBracket.end,
      body.rightBracket.offset,
    );
    final sorted = [...removed]..sort((a, b) => b.offset.compareTo(a.offset));
    for (final member in sorted) {
      rest = rest.replaceRange(
        member.offset - body.leftBracket.end,
        member.end - body.leftBracket.end,
        '',
      );
    }

    return rest.trim().isEmpty;
  }

  /// The ranges to delete for removing [removed] from [body].
  ///
  /// Members on lines of their own are deleted with their lines, and blank
  /// lines that would end up doubled or next to a brace go with them.
  static List<SourceRange> _deletions(
    String content,
    LineInfo lineInfo,
    BlockClassBody body,
    List<ClassMember> removed,
  ) {
    int lineOf(int offset) => lineInfo.getLocation(offset).lineNumber - 1;
    int lineStart(int line) => lineInfo.getOffsetOfLine(line);
    int lineEnd(int line) => line + 1 < lineInfo.lineCount
        ? lineInfo.getOffsetOfLine(line + 1)
        : content.length;
    bool isBlank(int line) =>
        content.substring(lineStart(line), lineEnd(line)).trim().isEmpty;

    final openLine = lineOf(body.leftBracket.offset);
    final closeLine = lineOf(body.rightBracket.offset);
    final deleted = <int>{};
    final ranges = <SourceRange>[];

    for (final member in removed) {
      final first = lineOf(member.offset);
      final last = lineOf(member.end);
      final before = content.substring(lineStart(first), member.offset);
      final after = content.substring(member.end, lineEnd(last));

      if (first > openLine &&
          last < closeLine &&
          before.trim().isEmpty &&
          after.trim().isEmpty) {
        deleted.addAll([for (var l = first; l <= last; l++) l]);
      } else {
        ranges.add(range.node(member));
      }
    }

    // Collapse blank lines left behind around the deleted ones.
    var changed = true;
    while (changed) {
      changed = false;
      for (final line in deleted.toList()) {
        if (deleted.contains(line - 1)) {
          continue;
        }

        var end = line;
        while (deleted.contains(end + 1)) {
          end++;
        }

        final previous = line - 1;
        final next = end + 1;

        if (next < closeLine &&
            isBlank(next) &&
            (previous == openLine || isBlank(previous))) {
          deleted.add(next);
          changed = true;
        } else if (previous > openLine &&
            isBlank(previous) &&
            next == closeLine) {
          deleted.add(previous);
          changed = true;
        }
      }
    }

    final lines = deleted.toList()..sort();
    for (var i = 0; i < lines.length; i++) {
      final first = lines[i];
      while (i + 1 < lines.length && lines[i + 1] == lines[i] + 1) {
        i++;
      }
      ranges.add(
        range.startOffsetEndOffset(lineStart(first), lineEnd(lines[i])),
      );
    }

    return ranges;
  }

  /// The indentation of the line holding [offset].
  static String _indentOf(String content, LineInfo lineInfo, int offset) {
    final line = lineInfo.getLocation(offset).lineNumber - 1;
    final start = lineInfo.getOffsetOfLine(line);
    final prefix = content.substring(start, offset);
    return prefix.trim().isEmpty ? prefix : '';
  }
}
