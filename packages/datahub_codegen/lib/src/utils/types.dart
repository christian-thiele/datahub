import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

String typeImportPrefix(DartType type, LibraryElement library) {
  if (type.element?.library case LibraryElement(uri: final typeLibraryUri)) {
    for (final import in library.fragments.expand(
      (f) => f.prefixes.expand((p) => p.imports),
    )) {
      final exportedLibraries = <LibraryElement>[
        import.importedLibrary!,
        ...import.importedLibrary!.exportedLibraries,
      ];

      for (final exported in exportedLibraries) {
        if (exported case LibraryElement(
          uri: final importLibraryUri,
        ) when importLibraryUri == typeLibraryUri) {
          if (import.prefix case PrefixFragment(
            element: PrefixElement(:final displayName),
          )) {
            return '$displayName.';
          }
        }
      }
    }
  }
  return '';
}

String typeExpression(DartType type, LibraryElement library) {
  return switch (type) {
    ParameterizedType(:final typeArguments, :final element?)
        when typeArguments.isNotEmpty =>
      '${element.displayName}<${typeArguments.map((e) => typeImportPrefix(e, library) + typeExpression(e, library)).join(', ')}>',
    DartType(:final element?) => element.displayName,
    DartType() => type.getDisplayString(),
  };
}
