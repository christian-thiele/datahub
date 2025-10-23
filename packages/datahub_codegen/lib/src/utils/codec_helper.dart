import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:datahub/data.dart';
import 'package:datahub_codegen/utils.dart';
import 'package:source_gen/source_gen.dart';

import 'writer.dart';

class CodecHelper {
  const CodecHelper._();

  static String encodingFunction(
    LibraryElement2 library,
    DartType type,
    String codec, {
    bool nonNull = false,
  }) {
    if (type.nullabilitySuffix == NullabilitySuffix.question && !nonNull) {
      return '(v) => $codec.encodeNullable(v, ${encodingFunction(library, type, codec, nonNull: true)})';
    }

    if (type.element3 == null) {
      throw Exception('Invalid type for encoding: $type');
    }

    if (TypeChecker.typeNamed(Data).hasAnnotationOf(type.element3!)) {
      return '(v) => v.toJson()';
    }

    if (type.element3 is EnumElement2) {
      return '$codec.encodeEnum';
    }

    if (type.isDartCoreList || type.isDartCoreMap) {
      return '(v) => ${encodingStatement(library, type, codec, 'v', nonNull: nonNull)}';
    }

    return '$codec.encode${firstUp(type.element3!.displayName)}';
  }

  static String decodingFunction(
    LibraryElement2 library,
    DartType type,
    String codec, {
    bool nonNull = false,
  }) {
    if (type.nullabilitySuffix == NullabilitySuffix.question && !nonNull) {
      return '(v, {String? name}) => $codec.decodeNullable(v, ${decodingFunction(library, type, codec, nonNull: true)}, name: name)';
    }

    if (type.element3 == null) {
      throw Exception('Invalid type for decoding: $type');
    }

    if (type.element3 is EnumElement2) {
      return '(v, {String? name}) => $codec.decodeEnum(v, ${type.element3!.displayName}.values, name: name)';
    }

    if (type.isDartCoreList || type.isDartCoreMap) {
      return '(v, {String? name}) => ${decodingStatement(library, type, codec, 'v', 'name', nonNull: nonNull)}';
    }

    if (TypeChecker.typeNamed(Data).hasAnnotationOf(type.element3!)) {
      final dataDeclarationName = typeExpression(type, library);
      final typeName = dataDeclarationName.startsWith('\$')
          ? dataDeclarationName.substring(1)
          : dataDeclarationName;
      return '${typeImportPrefix(type, library)}\$$typeName.bean.fromJson';
    }

    return '$codec.decode${firstUp(type.element3!.displayName)}';
  }

  static String encodingStatement(
    LibraryElement2 library,
    DartType type,
    String codec,
    String value, {
    bool nonNull = false,
  }) {
    if (type.nullabilitySuffix == NullabilitySuffix.question && !nonNull) {
      return '$codec.encodeNullable($value, ${encodingFunction(library, type, codec, nonNull: true)})';
    }

    if (type.element3 == null) {
      throw Exception('Invalid type for encoding: $type');
    }

    if (TypeChecker.typeNamed(Data).hasAnnotationOf(type.element3!)) {
      return '$value.toJson()';
    }

    if (type.isDartCoreList) {
      final valueType = (type as ParameterizedType).typeArguments[0];
      final typeName = typeImportPrefix(valueType, library) +
          typeExpression(valueType, library);

      final encodeItem = encodingFunction(library, valueType, codec);
      return '$codec.encodeList<$typeName>($value, $encodeItem)';
    } else if (type.isDartCoreMap) {
      final valueType = (type as ParameterizedType).typeArguments[1];
      final typeName = typeImportPrefix(valueType, library) +
          typeExpression(valueType, library);

      final encodeItem = encodingFunction(library, valueType, codec);
      return '$codec.encodeMap<$typeName>($value, $encodeItem)';
    } else {
      return '${encodingFunction(library, type, codec)}($value)';
    }
  }

  static String decodingStatement(
    LibraryElement2 library,
    DartType type,
    String codec,
    String value,
    String name, {
    bool nonNull = false,
  }) {
    if (type.nullabilitySuffix == NullabilitySuffix.question && !nonNull) {
      final decodeItem = decodingFunction(library, type, codec, nonNull: true);
      return '$codec.decodeNullable($value, $decodeItem, name: $name)';
    }

    if (type.element3 == null) {
      throw Exception('Invalid type for decoding: $type');
    }

    if (type.element3 is EnumElement2) {
      final typeName =
          typeImportPrefix(type, library) + typeExpression(type, library);
      return '$codec.decodeEnum($value, $typeName.values, name: name)';
    }

    if (type.isDartCoreList) {
      final valueType = (type as ParameterizedType).typeArguments[0];
      final typeName = typeImportPrefix(valueType, library) +
          typeExpression(valueType, library);
      final decodeItem = decodingFunction(library, valueType, codec);
      return '$codec.decodeList<$typeName>($value, $decodeItem, name: $name)';
    } else if (type.isDartCoreMap) {
      final valueType = (type as ParameterizedType).typeArguments[1];
      final typeName = typeImportPrefix(valueType, library) +
          typeExpression(valueType, library);
      final decodeItem = decodingFunction(library, valueType, codec);
      return '$codec.decodeMap<$typeName>($value, $decodeItem, name: $name)';
    } else {
      return '${decodingFunction(library, type, codec)}($value, name: $name)';
    }
  }
}
