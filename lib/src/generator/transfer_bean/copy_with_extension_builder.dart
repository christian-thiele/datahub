
import 'transfer_field.dart';

class CopyWithExtensionBuilder {
  final String transferClass;
  final List<TransferField> fields;

  CopyWithExtensionBuilder(this.transferClass, this.fields);

  Iterable<String> build() sync* {
    yield 'extension ${transferClass}CopyExtension on $transferClass {';
    yield* buildCopyWithMethod();
    yield '}';
  }

  Iterable<String> buildCopyWithMethod() sync* {
    yield '$transferClass copyWith({';

    for (final field in fields) {
      yield '${field.type.typeName}? ${field.name},';
      if (field.nullable) {
        yield 'bool null${_firstUpper(field.name)} = false,';
      }
    }

    yield '}) { return $transferClass(';

    for (final field in fields) {
      final valueStatement = field.nullable
          ? 'null${_firstUpper(field.name)} ? null : (${field.name} ?? this.${field.name})'
          : '${field.name} ?? this.${field.name}';

      if (field.named) {
        yield '${field.name}: $valueStatement,';
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
