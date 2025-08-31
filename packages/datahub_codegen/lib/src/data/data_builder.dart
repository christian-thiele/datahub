import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:datahub/data.dart';
import 'package:datahub_codegen/src/utils/types.dart';
import 'package:datahub_codegen/utils.dart';
import 'package:source_gen/source_gen.dart';

Builder dataBuilder(BuilderOptions options) =>
    SharedPartBuilder([DataBuilder()], 'data');

class MetaField {
  final FieldElement element;
  final List<DartObject> constraints;

  String get name => element.displayName;

  String get key => name;

  DartType get type => element.type;

  String get typeName =>
      typeExpression(type) +
      (type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '');

  MetaField(
    this.element,
    this.constraints,
  );

  String buildEncodingStatement(String value) =>
      CodecHelper.encodingStatement(type, '\$codec', value);

  String buildDecodingStatement(String value, String name) =>
      CodecHelper.decodingStatement(type, '\$codec', value, name);
}

class DataBuilder extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final dataChecker = TypeChecker.typeNamed(Data);
    final dataClasses = library.classes.where(dataChecker.hasAnnotationOf);
    final ln = Writer();
    for (final dataClass in dataClasses) {
      final className = dataClass.displayName;
      final constructor = findDataConstructor(dataClass);

      final fields = [
        for (final field in dataClass.fields.where((e) => e.isFinal))
          MetaField(
            field,
            TypeChecker.typeNamed(DataFieldConstraint)
                .annotationsOf(field)
                .toList(),
          ),
      ];

      ln(generateClass(className, constructor, fields));
    }

    return ln.toString();
  }

  String generateClass(
    String className,
    ConstructorElement constructor,
    List<MetaField> fields,
  ) {
    final ln = Writer();
    ln('abstract class _$className with DataObject<$className> {');
    ln('const _$className();');

    for (final field in fields) {
      ln(generateField(className, field));
    }

    ln('static final DataBean<$className> bean = DataBean<$className>(');
    ln('name: \'$className\',');
    ln('fields: List<DataField<$className, dynamic>>.unmodifiable([');
    for (final field in fields) {
      ln('\$${field.name},');
    }
    ln(']),');
    ln('fromJson: fromJson,');
    ln(');');

    ln('@override String get \$\$name => bean.name;');
    ln('@override List<DataField<$className, dynamic>> get \$\$fields => bean.fields;');

    ln(generateCopyWith(className, fields));
    ln(generateFromJson(className, fields));
    ln(generateToJson(className, fields));

    ln('}');
    return ln.toString();
  }

  String generateField(String className, MetaField field) {
    final ln = Writer();
    ln('static final \$${field.name} = DataField<$className, ${field.typeName}>(');
    ln('name: \'${field.name}\', valueOf: (p)=>p.${field.name}');
    ln(');');
    return ln.toString();
  }

  String generateConstructor(String className, ConstructorElement constructor) {
    final ln = Writer();
    ln('const $className(');

    final positionalParameters =
        constructor.formalParameters.where((e) => e.isPositional);
    for (final parameter in positionalParameters) {
      ln('super.${parameter.displayName},');
    }

    final namedParameters =
        constructor.formalParameters.where((e) => e.isNamed);
    if (namedParameters.isNotEmpty) {
      ln('{');
      for (final parameter in namedParameters) {
        if (parameter.isRequired) {
          ln.w('required ');
        }
        ln.w('super.');
        ln.w(parameter.displayName);
        ln.w(',');
      }
      ln('}');
    }
    ln(');');
    return ln.toString();
  }

  String generateFromJson(String className, List<MetaField> fields) {
    final ln = Writer();
    ln('static $className fromJson(dynamic data, {String? name}) {');
    ln('if (data is! Map<String, dynamic>) {');
    ln('throw CodecException.typeMismatch($className, data.runtimeType, name);');
    ln('}');

    ln('final \$codec = const JsonDataCodec();');
    ln('return $className(');
    for (final field in fields) {
      final decodingStatement = field.buildDecodingStatement(
        'data[\'${field.key}\']',
        'DataCodec.childName(name, \'${field.key}\')',
      );
      ln("${field.name}: $decodingStatement,");
    }
    ln(');');
    ln('}');
    return ln.toString();
  }

  String generateToJson(String className, List<MetaField> fields) {
    final ln = Writer();
    ln('@override Map<String, dynamic> toJson() {');
    ln('final \$codec = const JsonDataCodec();');
    ln('final \$data = this as $className;');
    ln('return {');
    for (final field in fields) {
      final encodingStatement =
          field.buildEncodingStatement('\$data.${field.name}');
      ln("'${field.key}': $encodingStatement,");
    }
    ln('}..removeWhere((k, v) => v == null); }');
    return ln.toString();
  }

  String generateCopyWith(String className, List<MetaField> fields) {
    final ln = Writer();
    ln('$className copyWith(${fields.isNotEmpty ? '{' : ''}');

    for (final field in fields) {
      final fieldNullable =
          field.type.nullabilitySuffix != NullabilitySuffix.none;
      ln('${typeExpression(field.type)}? ${field.name},');
      if (fieldNullable) {
        ln('bool null${firstUp(field.name)} = false,');
      }
    }

    ln('${fields.isNotEmpty ? '}' : ''}) { ');

    ln('final \$data = this as $className;');
    ln('return $className(');

    for (final field in fields) {
      final fieldNullable =
          field.type.nullabilitySuffix != NullabilitySuffix.none;

      final valueStatement = fieldNullable
          ? 'null${firstUp(field.name)} ? null : (${field.name} ?? \$data.${field.name})'
          : '${field.name} ?? \$data.${field.name}';

      ln('${field.name}: $valueStatement,');
    }

    ln('); }');

    return ln.toString();
  }
}

ConstructorElement findDataConstructor(ClassElement dataClass) {
  return dataClass.constructors.firstWhere(
    (e) => e.name == 'new' && e.isConst,
    orElse: () => throw Exception(
        'Data class ${dataClass.displayName} does not provide a unnamed const constructor.'),
  );
}
