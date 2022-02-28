import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:boost/boost.dart';
import 'package:build/build.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:source_gen/source_gen.dart';

import '../generate_config.dart';
import '../config_option.dart';

class ConfigGenerator extends GeneratorForAnnotation<GenerateConfig> {
  @override
  Stream<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async* {
    if (element is! ClassElement) {
      throw BoostException(
          'Annotation GenerateConfig must be used on a class.');
    }

    final className = element.name;
    final envPrefix =
        (annotation.read('envPrefix').literalValue as String?) ?? '';

    if (element.unnamedConstructor == null) {
      throw BoostException(
          'Annotated class must provide an unnamed default constructor.');
    }

    if (element.hasNonFinalField) {
      throw BoostException('Class must be immutable (no non-final fields).');
    }

    final constructor = element.unnamedConstructor!;
    if (constructor.parameters
        .any((element) => !element.isInitializingFormal)) {
      throw BoostException(
          'All default constructor parameters must be initializing formals!');
    }

    final options = constructor.parameters.map((p) {
      final field = element.fields.firstWhere((f) => f.name == p.name);
      final fieldAnnotation = TypeChecker.fromRuntime(ConfigOption)
          .firstAnnotationOfExact(field, throwOnUnresolved: false);
      final fieldAbbr = readField<String>(fieldAnnotation, 'abbr');
      final fieldEnv = readField<String>(fieldAnnotation, 'env');
      final fieldDefaultValue =
          readField<dynamic>(fieldAnnotation, 'defaultValue');
      return _ConfigOption(
        field.name,
        fieldAbbr,
        envPrefix + (fieldEnv ?? field.name.toUpperCase()),
        _findType(field),
        _findPrimitiveType(field),
        fieldDefaultValue,
        p,
      );
    });

    yield '$className loadConfig([List<String>? args]) {\n'
        'final parser = ConfigParser();';

    for (final option in options) {
      yield option.build();
    }

    yield 'final data = parser.parse(args);';
    yield 'return $className(';

    for (final option in options) {
      final accessor = option.buildAccessor();
      final namePrefix = option.param.isNamed ? '${option.param.name}: ' : '';
      yield namePrefix + accessor + ',\n';
    }

    yield ');\n}';
  }

  Type _findType(FieldElement field) {
    if (field.type.isDartCoreBool) {
      return bool;
    } else if (field.type.isDartCoreInt) {
      return int;
    } else if (field.type.isDartCoreString) {
      return String;
    } else if (field.type.isDartCoreDouble) {
      return double;
    } else if (field.type.element?.name == 'Directory') {
      return Directory;
    } else if (field.type.element?.name == 'File') {
      return File;
    } else {
      throw BoostException('Invalid field type ${field.type.element?.name}.');
    }
  }

  Type _findPrimitiveType(FieldElement field) {
    if (field.type.isDartCoreBool) {
      return bool;
    } else if (field.type.isDartCoreInt) {
      return int;
    } else if (field.type.isDartCoreString) {
      return String;
    } else if (field.type.isDartCoreDouble) {
      return double;
    } else if (field.type.element?.name == 'Directory') {
      return String;
    } else if (field.type.element?.name == 'File') {
      return String;
    } else {
      throw BoostException('Invalid field type ${field.type.element?.name}.');
    }
  }
}

class _ConfigOption {
  final String name;
  final String? abbr;
  final String? env;
  final Type type;
  final Type primitiveType;
  final dynamic defaultValue;
  final ParameterElement param;

  _ConfigOption(
    this.name,
    this.abbr,
    this.env,
    this.type,
    this.primitiveType,
    this.defaultValue,
    this.param,
  );

  String build() {
    final buffer = StringBuffer('parser.addOption(');
    buffer.write("'$name'");
    if (abbr != null) {
      buffer.write(", abbr: '$abbr'");
    }
    if (env != null) {
      buffer.write(", environment: '$env'");
    }
    if (defaultValue != null) {
      buffer.write(', defaultValue: ${valueToLiteral(defaultValue)}');
    }
    buffer.write(', required: ${param.isNotOptional && defaultValue == null}');

    buffer.write(', type: $primitiveType');
    buffer.write(');');
    return buffer.toString();
  }

  String buildAccessor() {
    final raw = "data['$name']";
    if (type == primitiveType) {
      return raw;
    } else if (type == File) {
      if (param.isOptional) {
        return '$raw != null ? File($raw) : null';
      } else {
        return 'File($raw)';
      }
    } else if (type == Directory) {
      if (param.isOptional) {
        return '$raw != null ? Directory($raw) : null';
      } else {
        return 'Directory($raw)';
      }
    } else {
      throw BoostException('Invalid type $type.');
    }
  }
}

String valueToLiteral(dynamic value) {
  if (value is String) {
    return "'$value'";
  } else {
    return '$value';
  }
}

T? readField<T>(DartObject? element, String fieldName) {
  if (element == null) {
    return null;
  }

  final reader = ConstantReader(element);
  final valueReader = reader.read(fieldName);

  if (valueReader.isNull) {
    return null;
  }
  return valueReader.literalValue as T?;
}
