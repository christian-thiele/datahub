import 'dart:typed_data';

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
  if (element is! ClassElement) {
    throw Exception('Annotation must be used on a class.');
  }

  if (element.unnamedConstructor == null) {
    throw Exception(
        'Annotated class must provide an unnamed default constructor.');
  }

  if (element.hasNonFinalField) {
    throw Exception('Annotated class must not have non-final fields.');
  }

  final constructor = element.unnamedConstructor!;

  if (constructor.parameters.any((element) => !element.isInitializingFormal)) {
    throw Exception(
        'All default constructor parameters must be initializing formals!');
  }

  return element;
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
}
