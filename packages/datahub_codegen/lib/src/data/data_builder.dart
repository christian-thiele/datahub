import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
import 'package:datahub_codegen/utils.dart';
import 'package:source_gen/source_gen.dart';

Builder dataBuilder(BuilderOptions options) =>
    SharedPartBuilder([DataBuilder()], 'data');

class MetaField {
  final LibraryElement2 library;
  final FieldElement2 element;
  final List<DartObject> constraints;
  final List<DartObject> meta;
  final String? defaultValueExpression;
  final String key;
  final String name;

  DartType get type => element.type;

  String get importPrefix => typeImportPrefix(type, library);

  String get typeName => typeExpression(type, library);

  String get typeNameNullable =>
      typeName +
      (type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '');

  String get prefixedTypeNameNullable => importPrefix + typeNameNullable;

  MetaField({
    required this.name,
    required this.key,
    required this.element,
    required this.constraints,
    required this.meta,
    required this.defaultValueExpression,
    required this.library,
  });

  String buildEncodingStatement(String value) =>
      CodecHelper.encodingStatement(library, type, '\$\$codec', value);

  String buildDecodingStatement(String value, String name) =>
      CodecHelper.decodingStatement(library, type, '\$\$codec', value, name);
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
      final dataAnnotation = dataChecker.firstAnnotationOfExact(dataClass);
      final namingConventionIndex = ConstantReader(dataAnnotation)
          .read('defaultNamingConvention')
          .objectValue
          .getField('index')!
          .toIntValue()!;
      final namingConvention = NamingConvention.values[namingConventionIndex];

      final fields = [
        for (final param in constructor.formalParameters
            .whereType<FieldFormalParameterElement2>()
            .where((e) => e.isNamed && e.field2 != null))
          MetaField(
            name: param.field2!.displayName,
            key: fieldKey(param.field2!, namingConvention),
            element: param.field2!,
            constraints: TypeChecker.typeNamed(DataFieldConstraint)
                .annotationsOf(param.field2!)
                .toList(),
            meta: TypeChecker.typeNamed(MetaData)
                .annotationsOf(param.field2!)
                .toList(),
            defaultValueExpression: getDefaultValueExpression(param),
            library: param.field2!.library2,
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
    ln('abstract interface class \$$className with DataObject<$className> {');
    ln('const \$$className();');
    ln('static const \$\$codec = JsonDataCodec();');

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
    ln('static final \$${field.name} = DataField<$className, ${field.prefixedTypeNameNullable}>(');
    ln('name: \'${field.name}\',');
    ln('valueOf: (p)=>p.${field.name},');

    final valueWithDefault = switch (field.defaultValueExpression) {
      final val? => '(value ?? $val)',
      _ => 'value',
    };
    final decodingStatement =
        field.buildDecodingStatement(valueWithDefault, 'name');
    final encodingStatement = field.buildEncodingStatement('value');

    if (TypeChecker.typeNamed(Data).hasAnnotationOf(field.type.element3!)) {
      ln('dataBean: () => ${field.importPrefix}\$${field.typeName}.bean,');
    } else if (field.type
        case ParameterizedType(
          isDartCoreList: true,
          typeArguments: [final type]
        )
        when type.element3 != null &&
            TypeChecker.typeNamed(Data).hasAnnotationOf(type.element3!)) {
      ln('dataBean: () => ${typeImportPrefix(type, field.library)}\$${type.element3!.displayName}.bean,');
    } else if (field.type
        case ParameterizedType(
          isDartCoreMap: true,
          typeArguments: [..., final type]
        )
        when type.element3 != null &&
            TypeChecker.typeNamed(Data).hasAnnotationOf(type.element3!)) {
      ln('dataBean: () => ${typeImportPrefix(type, field.library)}\$${type.element3!.displayName}.bean,');
    }

    ln('fromJson: (value, {String? name}) => $decodingStatement,');
    ln('toJson: (value) => $encodingStatement,');

    if (field.meta.isNotEmpty) {
      ln('meta: [${field.meta.map(metaInvocation).join(', ')},],');
    }

    final constraintInvocations =
        field.constraints.map(metaInvocation).toList();
    if (field.type.element3 is EnumElement2) {
      constraintInvocations.add(
          'EnumConstraint(values: ${field.importPrefix}${field.typeName}.values)');
    } else if (field.type
        case ParameterizedType(
          isDartCoreList: true,
          typeArguments: [final DartType type]
        ) when type.element3 is EnumElement2) {
      final typeName = typeImportPrefix(type, field.library) +
          typeExpression(type, field.library);
      constraintInvocations.add('EnumConstraint(values: $typeName.values)');
    } else if (field.type
        case ParameterizedType(
          isDartCoreMap: true,
          typeArguments: [..., final DartType type]
        ) when type.element3 is EnumElement2) {
      final typeName = typeImportPrefix(type, field.library) +
          typeExpression(type, field.library);
      constraintInvocations.add('EnumConstraint(values: $typeName.values)');
    }

    if (constraintInvocations.isNotEmpty) {
      ln('constraints: [${constraintInvocations.join(', ')},],');
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

    ln('return $className(');
    for (final field in fields) {
      ln('${field.name}: \$${field.name}.fromJson(data[\'${field.key}\'], name: DataCodec.childName(name, \'${field.key}\')),');
    }
    ln(');');
    ln('}');
    return ln.toString();
  }

  String generateToJson(String className, List<MetaField> fields) {
    final ln = Writer();
    ln('@override Map<String, dynamic> toJson() {');
    ln('final \$\$data = this as $className;');
    ln('return {');
    for (final field in fields) {
      ln("'${field.key}': \$${field.name}.toJson(\$\$data.${field.name}),");
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
      ln('${field.importPrefix}${field.typeName}? ${field.name},');
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

  String fieldKey(
      FieldElement2 field, NamingConvention defaultNamingConvention) {
    final checker = TypeChecker.typeNamed(JsonKey);
    if (checker.firstAnnotationOf(field) case final annotation?) {
      return annotation.getField('key')!.toStringValue()!;
    }
    return toNamingConvention(field.displayName, defaultNamingConvention);
  }
}

ConstructorElement2 findDataConstructor(ClassElement2 dataClass) {
  return dataClass.constructors2.firstWhere(
    (e) => e.name3 == 'new' && e.isConst,
    orElse: () => throw Exception(
        'Data class ${dataClass.displayName} does not provide an unnamed const constructor.'),
  );
}
