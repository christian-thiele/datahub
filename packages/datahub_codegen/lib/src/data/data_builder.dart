import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
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
  final FieldElement2 element;
  final List<DartObject> constraints;
  final List<DartObject>? meta;
  final String? defaultValueExpression;

  String get name => element.displayName;

  String get key => name;

  DartType get type => element.type;

  String get typeName =>
      typeExpression(type) +
      (type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '');

  MetaField(
    this.element,
    this.constraints,
    this.meta,
    this.defaultValueExpression,
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
        for (final param in constructor.formalParameters
            .whereType<FieldFormalParameterElement2>()
            .where((e) => e.isNamed && e.field2 != null))
          MetaField(
            param.field2!,
            TypeChecker.typeNamed(DataFieldConstraint)
                .annotationsOf(param.field2!)
                .toList(),
            TypeChecker.typeNamed(MetaData)
                .annotationsOf(param.field2!)
                .toList(),
            getDefaultValueExpression(param),
          ),
      ];

      ln(generateClass(
        className,
        constructor,
        fields,
        TypeChecker.typeNamed(MetaData).annotationsOf(dataClass).toList(),
      ));
    }

    return ln.toString();
  }

  String generateClass(
    String className,
    ConstructorElement2 constructor,
    List<MetaField> fields,
    List<DartObject> metaAnnotations,
  ) {
    final ln = Writer();
    ln('abstract class _$className with DataObject<$className> {');
    ln('const _$className();');

    for (final field in fields) {
      ln(generateField(className, field));
    }

    ln(generateDataBean(className, fields, metaAnnotations));

    ln('@override String get \$\$name => bean.name;');
    ln('@override List<DataField<$className, dynamic>> get \$\$fields => bean.fields;');

    ln(generateCopyWith(className, fields));
    ln(generateFromValues(className, fields));
    ln(generateFromJson(className, fields));
    ln(generateToJson(className, fields));

    ln('}');
    return ln.toString();
  }

  String generateField(String className, MetaField field) {
    final ln = Writer();
    ln('static final \$${field.name} = DataField<$className, ${field.typeName}>(');
    ln('name: \'${field.name}\', valueOf: (p)=>p.${field.name},');
    final meta = TypeChecker.typeNamed(MetaData).annotationsOf(field.element);
    if (meta.isNotEmpty) {
      ln('meta: [${meta.map(metaInvocation).join(', ')},],');
    }
    ln(');');
    return ln.toString();
  }

  String generateConstructor(
      String className, ConstructorElement2 constructor) {
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

  String generateFromValues(String className, List<MetaField> fields) {
    final ln = Writer();
    ln('static $className fromValues(Map<String, dynamic> data) {');
    ln('return $className(');
    for (final field in fields) {
      ln('${field.name}: data[\'${field.name}\']');
      if (field.defaultValueExpression != null) {
        ln(' ?? ${field.defaultValueExpression},');
      } else {
        ln(',');
      }
    }
    ln(');');
    ln('}');
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
      final accessor = switch (field.defaultValueExpression) {
        final val? => '(data[\'${field.key}\'] ?? $val)',
        _ => 'data[\'${field.key}\']',
      };

      final decodingStatement = field.buildDecodingStatement(
        accessor,
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

  String generateDataBean(
    String className,
    List<MetaField> fields,
    List<DartObject> meta,
  ) {
    final ln = Writer();

    ln('static final DataBean<$className> bean = DataBean<$className>(');
    ln('name: \'$className\',');
    ln('fields: List<DataField<$className, dynamic>>.unmodifiable([');
    for (final field in fields) {
      ln('\$${field.name},');
    }
    ln(']),');
    ln('fromValues: fromValues,');
    ln('fromJson: fromJson,');

    if (meta.isNotEmpty) {
      ln('meta: [${meta.map(metaInvocation).join(', ')},],');
    }

    ln(');');

    return ln.toString();
  }
}

ConstructorElement2 findDataConstructor(ClassElement2 dataClass) {
  return dataClass.constructors2.firstWhere(
    (e) => e.name3 == 'new' && e.isConst,
    orElse: () => throw Exception(
        'Data class ${dataClass.displayName} does not provide a unnamed const constructor.'),
  );
}
