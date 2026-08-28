import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// Package names of the DataHub framework packages that rules key on.
abstract final class DatahubPackages {
  static const datahub = 'datahub';
  static const postgres = 'datahub_postgres';
  static const aperture = 'datahub_aperture';
}

/// Whether [element] is declared in [package].
///
/// Matching is done on the package name only, never on the `src/...` path
/// below it, so that moving a declaration inside the framework does not
/// silently disable a rule.
bool isFromPackage(Element? element, String package) {
  final uri = element?.library?.uri;
  if (uri == null || uri.scheme != 'package') {
    return false;
  }

  final segments = uri.pathSegments;
  return segments.isNotEmpty && segments.first == package;
}

/// Whether [element] is the class [name] declared in [package].
bool isClass(
  Element? element,
  String name, {
  String package = DatahubPackages.datahub,
}) =>
    element is InterfaceElement &&
    element.name == name &&
    isFromPackage(element, package);

/// Whether [type] is (an instantiation of) the class [name] from [package].
bool isType(
  DartType? type,
  String name, {
  String package = DatahubPackages.datahub,
}) => type is InterfaceType && isClass(type.element, name, package: package);

/// Whether [element] is `ServiceInstance` or a subtype of it.
bool isServiceInstanceSubtype(InterfaceElement? element) {
  if (element == null) {
    return false;
  }

  if (isClass(element, 'ServiceInstance')) {
    return true;
  }

  return element.allSupertypes.any(
    (s) => isClass(s.element, 'ServiceInstance'),
  );
}

/// Whether [element] implements `Service`.
bool isServiceSubtype(InterfaceElement? element) {
  if (element == null) {
    return false;
  }

  return element.allSupertypes.any((s) => isClass(s.element, 'Service'));
}

/// Whether [type] is `Find<T>`.
bool isFindType(DartType? type) => isType(type, 'Find');

/// Whether [type] is `Config<T>` or one of its subclasses.
bool isConfigType(DartType? type) {
  if (type is! InterfaceType) {
    return false;
  }

  if (isClass(type.element, 'Config')) {
    return true;
  }

  return type.allSupertypes.any((s) => isClass(s.element, 'Config'));
}

/// Returns the enum type argument of a `Config<E>` / `Config<E?>` [type], or
/// `null` when the type argument is not an enum.
InterfaceElement? enumTypeArgumentOf(DartType? type) {
  if (type is! InterfaceType || type.typeArguments.length != 1) {
    return null;
  }

  final argument = type.typeArguments.single;
  if (argument is! InterfaceType) {
    return null;
  }

  final element = argument.element;
  return element is EnumElement ? element : null;
}
