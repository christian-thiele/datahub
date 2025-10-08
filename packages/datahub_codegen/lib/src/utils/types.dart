import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';

String typeImportPrefix(DartType type, LibraryElement2 library) {
  if (type.element3?.library2 case LibraryElement2(uri: final typeLibraryUri)) {
    for (final import in library.fragments
        .expand((f) => f.prefixes.expand((p) => p.imports))) {
      final exportedLibraries = <LibraryElement2>[
        import.importedLibrary2!,
        ...import.importedLibrary2!.exportedLibraries2,
      ];

      for (final exported in exportedLibraries) {
        if (exported case LibraryElement2(uri: final importLibraryUri)
            when importLibraryUri == typeLibraryUri) {
          if (import.prefix2
              case PrefixFragment(
                element: PrefixElement2(:final displayName)
              )) {
            return '$displayName.';
          }
        }
      }
    }
  }
  return '';
}

String typeExpression(DartType type, LibraryElement2 library) {
  return switch (type) {
    ParameterizedType(:final typeArguments, :final element3?)
        when typeArguments.isNotEmpty =>
      '${element3.displayName}<${typeArguments.map((e) => typeImportPrefix(e, library) + typeExpression(e, library)).join(', ')}>',
    DartType(:final element3?) => element3.displayName,
    DartType() => type.getDisplayString(),
  };
}
