import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:boost/boost.dart';

class CopyWithExtensionBuilder {
  final String transferClass;
  final List<Tuple<FieldElement, ParameterElement>> fields;

  CopyWithExtensionBuilder(this.transferClass, this.fields);

  Iterable<String> build() sync* {
    yield 'extension ${transferClass}CopyExtension on $transferClass {';
    yield* buildCopyWithMethod();
    yield '}';
  }

  Iterable<String> buildCopyWithMethod() sync* {
    yield '$transferClass copyWith({';

    for (final field in fields) {
      final typeName = field.a.type.getDisplayString(withNullability: false);

      final fieldName = field.a.name;
      final fieldNullable =
          field.a.type.nullabilitySuffix != NullabilitySuffix.none;
      yield '$typeName? $fieldName,';
      if (fieldNullable) {
        yield 'bool null${_firstUpper(fieldName)} = false,';
      }
    }

    yield '}) { return $transferClass(';

    for (final field in fields) {
      final fieldName = field.a.name;
      final fieldNullable =
          field.a.type.nullabilitySuffix != NullabilitySuffix.none;

      final valueStatement = fieldNullable
          ? 'null${_firstUpper(fieldName)} ? null : ($fieldName ?? this.$fieldName)'
          : '$fieldName ?? this.$fieldName';

      if (field.b.isNamed) {
        yield '$fieldName: $valueStatement,';
      } else {
        yield '$valueStatement,';
      }
    }

    yield '); }';
  }

  String _firstUpper(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value.substring(0, 1).toUpperCase() + value.substring(1);
  }
}
