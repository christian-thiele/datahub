import 'dart:typed_data';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:boost/boost.dart';
import 'package:cl_datahub_common/common.dart';
import 'package:source_gen/source_gen.dart';

/// Asserts that element is an immutable PlainOldDartObject
/// - Element is ClassElement
/// - All fields of class are final
/// - Element has unnamed constructor
/// - Constructor has only initializing formals
ClassElement assertPodo(Element element) {
  final classElement = assertClass(element);

  if (classElement.unnamedConstructor == null) {
    throw Exception(
        'Annotated class must provide an unnamed default constructor.');
  }

  if (classElement.hasNonFinalField) {
    throw Exception('Annotated class must not have non-final fields.');
  }

  final constructor = classElement.unnamedConstructor!;

  if (constructor.parameters.any((p) => !p.isInitializingFormal)) {
    throw Exception(
        'All default constructor parameters must be initializing formals!');
  }

  return classElement;
}

/// Asserts that element is a class.
ClassElement assertClass(Element element) {
  if (element is ClassElement) {
    return element;
  }

  throw Exception('Annotation must be used on a class.');
}

/// Returns all PlainOldDartObject fields together with their
/// initializing parameters.
///
/// Includes [assertPodo]
List<Tuple<FieldElement, ParameterElement>> podoFields(
    ClassElement classElement) {
  return assertPodo(classElement)
      .unnamedConstructor!
      .parameters
      .map((p) =>
          Tuple(classElement.fields.firstWhere((f) => f.name == p.name), p))
      .toList();
}

/// Returns the dart literal equivalent to [value].
///
/// Works with String, int, double, bool, num, null.
String toLiteral(dynamic value) {
  if (value is String) {
    return "'${value.replaceAll('\'', '\\\'')}'";
  }

  return value.toString();
}

FieldElement? findTransferIdField(ClassElement element) {
  final idFields = podoFields(element).map((f) => f.a).where((f) =>
      TypeChecker.fromRuntime(TransferId)
          .firstAnnotationOfExact(f, throwOnUnresolved: false) !=
      null);
  if (idFields.length > 1) {
    throw Exception('Only 1 TransferId field is allowed on a TransferObject.');
  } else if (idFields.isNotEmpty) {
    return idFields.single;
  } else {
    return null;
  }
}

extension DartTypeExtension on DartType {
  /// Checks if [type] is a [TransferObject] annotated class.
  bool get isTransferObject {
    if (element == null) {
      return false;
    }

    return TypeChecker.fromRuntime(TransferObject)
            .firstAnnotationOfExact(element!, throwOnUnresolved: false) !=
        null;
  }

  bool get isDartCoreDateTime =>
      TypeChecker.fromRuntime(DateTime).isExactlyType(this);

  bool get isEnum =>
      (element is ClassElement) && (element as ClassElement).isEnum;

  bool get isUint8List =>
      TypeChecker.fromRuntime(Uint8List).isExactlyType(this);

  /// Json types are either List<dynamic> or Map<String, dynamic>
  bool get isJsonType {
    if (isDartCoreList) {
      return (this as ParameterizedType).typeArguments.first.isDynamic;
    } else if (isDartCoreMap) {
      final args = (this as ParameterizedType).typeArguments;
      return args.first.isDartCoreString && args[1].isDynamic;
    } else {
      return false;
    }
  }
}

DartObject? getAnnotation(Element element, Type annotationType) {
  return TypeChecker.fromRuntime(annotationType)
      .firstAnnotationOf(element, throwOnUnresolved: false);
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

DartType? readTypeField(DartObject? element, String fieldName) {
  if (element == null) {
    return null;
  }

  final reader = ConstantReader(element);
  final valueReader = reader.read(fieldName);

  if (valueReader.isNull) {
    return null;
  }
  return valueReader.typeValue;
}
