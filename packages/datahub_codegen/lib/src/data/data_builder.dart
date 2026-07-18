import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
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
  final LibraryElement library;
  final FieldElement element;
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
        for (final param
            in constructor.formalParameters
                .whereType<FieldFormalParameterElement>()
                .where((e) => e.isNamed && e.field != null))
          MetaField(
            name: param.field!.displayName,
            key: fieldKey(param.field!, namingConvention),
            element: param.field!,
            constraints: TypeChecker.typeNamed(
              DataFieldConstraint,
            ).annotationsOf(param.field!).toList(),
            meta: TypeChecker.typeNamed(
              MetaData,
            ).annotationsOf(param.field!).toList(),
            defaultValueExpression: getDefaultValueExpression(param),
            library: param.field!.library,
          ),
      ];

      ln(
        generateClass(
          className,
          constructor,
          fields,
          TypeChecker.typeNamed(MetaData).annotationsOf(dataClass).toList(),
        ),
      );
    }

    return ln.toString();
  }

  String generateClass(
    String className,
    ConstructorElement constructor,
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
    ln(
      '@override List<DataField<$className, dynamic>> get \$\$fields => bean.fields;',
    );

    ln(generateCopyWith(className, fields));
    ln(generateFromValues(className, fields));
    ln(generateFromJson(className, fields));
    ln(generateToJson(className, fields));

    ln('}');
    return ln.toString();
  }

  String generateField(String className, MetaField field) {
    final ln = Writer();
    ln(
      'static final \$${field.name} = DataField<$className, ${field.prefixedTypeNameNullable}>(',
    );
    ln('name: \'${field.name}\',');
    ln('valueOf: (p)=>p.${field.name},');

    final valueWithDefault = switch (field.defaultValueExpression) {
      final val? => '(value ?? $val)',
      _ => 'value',
    };
    final decodingStatement = field.buildDecodingStatement(
      valueWithDefault,
      'name',
    );
    final encodingStatement = field.buildEncodingStatement('value');

    if (TypeChecker.typeNamed(Data).hasAnnotationOf(field.type.element!)) {
      ln('dataBean: () => ${field.importPrefix}\$${field.typeName}.bean,');
    } else if (field.type
        case ParameterizedType(
          isDartCoreList: true,
          typeArguments: [final type],
        )
        when type.element != null &&
            TypeChecker.typeNamed(Data).hasAnnotationOf(type.element!)) {
      ln(
        'dataBean: () => ${typeImportPrefix(type, field.library)}\$${type.element!.displayName}.bean,',
      );
    } else if (field.type
        case ParameterizedType(
          isDartCoreMap: true,
          typeArguments: [..., final type],
        )
        when type.element != null &&
            TypeChecker.typeNamed(Data).hasAnnotationOf(type.element!)) {
      ln(
        'dataBean: () => ${typeImportPrefix(type, field.library)}\$${type.element!.displayName}.bean,',
      );
    }

    ln('fromJson: (value, {String? name}) => $decodingStatement,');
    ln('toJson: (value) => $encodingStatement,');

    if (field.meta.isNotEmpty) {
      ln('meta: [${field.meta.map(annotationInvocation).join(', ')},],');
    }

    final constraintInvocations = field.constraints
        .map(annotationInvocation)
        .toList();
    if (field.type.element is EnumElement) {
      constraintInvocations.add(
        'EnumConstraint(values: ${field.importPrefix}${field.typeName}.values)',
      );
    } else if (field.type case ParameterizedType(
      isDartCoreList: true,
      typeArguments: [final DartType type],
    ) when type.element is EnumElement) {
      final typeName =
          typeImportPrefix(type, field.library) +
          typeExpression(type, field.library);
      constraintInvocations.add('EnumConstraint(values: $typeName.values)');
    } else if (field.type case ParameterizedType(
      isDartCoreMap: true,
      typeArguments: [..., final DartType type],
    ) when type.element is EnumElement) {
      final typeName =
          typeImportPrefix(type, field.library) +
          typeExpression(type, field.library);
      constraintInvocations.add('EnumConstraint(values: $typeName.values)');
    }

    if (constraintInvocations.isNotEmpty) {
      ln('constraints: [${constraintInvocations.join(', ')},],');
    }
    ln(');');
    return ln.toString();
  }

  String generateConstructor(String className, ConstructorElement constructor) {
    final ln = Writer();
    ln('const $className(');

    final positionalParameters = constructor.formalParameters.where(
      (e) => e.isPositional,
    );
    for (final parameter in positionalParameters) {
      ln('super.${parameter.displayName},');
    }

    final namedParameters = constructor.formalParameters.where(
      (e) => e.isNamed,
    );
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
      final valueAccessor = 'data[\'${field.name}\']';

      final String accessor;
      if (field.type.isDartCoreList) {
        final valueType = (field.type as ParameterizedType).typeArguments[0];
        final typeName =
            typeImportPrefix(valueType, field.library) +
            typeExpression(valueType, field.library);
        accessor = '$valueAccessor?.cast<$typeName>().toList(growable: false)';
      } else {
        accessor = valueAccessor;
      }

      ln('${field.name}: $accessor');
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
    ln(
      'throw CodecException.typeMismatch($className, data.runtimeType, name);',
    );
    ln('}');

    ln('return $className(');
    for (final field in fields) {
      ln(
        '${field.name}: \$${field.name}.fromJson(data[\'${field.key}\'], name: DataCodec.childName(name, \'${field.key}\')),',
      );
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
      ln('meta: [${meta.map(annotationInvocation).join(', ')},],');
    }

    ln(');');

    return ln.toString();
  }

  String fieldKey(
    FieldElement field,
    NamingConvention defaultNamingConvention,
  ) {
    final checker = TypeChecker.typeNamed(JsonKey);
    if (checker.firstAnnotationOf(field) case final annotation?) {
      return annotation.getField('key')!.toStringValue()!;
    }
    return toNamingConvention(field.displayName, defaultNamingConvention);
  }
}

ConstructorElement findDataConstructor(ClassElement dataClass) {
  return dataClass.constructors.firstWhere(
    (e) => e.name == 'new' && e.isConst,
    orElse: () => throw Exception(
      'Data class ${dataClass.displayName} does not provide an unnamed const constructor.',
    ),
  );
}
