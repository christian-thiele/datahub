import 'transfer_field.dart';

class TransferBeanBuilder {
  final String transferClass;
  final List<TransferField> fields;

  TransferBeanBuilder(this.transferClass, this.fields);

  Iterable<String> build() sync* {
    yield '// ignore: constant_identifier_names';
    yield 'const ${transferClass}TransferBean = _${transferClass}TransferBeanImpl._();';
    yield 'class _${transferClass}TransferBeanImpl extends TransferBean<$transferClass> {';
    yield* buildConstConstructor();
    yield* buildToMapMethod();
    yield* buildToObjectMethod();
    yield '}';
  }

  Iterable<String> buildConstConstructor() sync* {
    yield 'const _${transferClass}TransferBeanImpl._();';
  }

  Iterable<String> buildToMapMethod() sync* {
    final objectName = 'transferObject';
    yield '@override Map<String, dynamic> toMap($transferClass $objectName) {';
    yield 'return {';
    for (final field in fields) {
      final encodingStatement = field.buildEncodingStatement(objectName);
      yield "'${field.key}': $encodingStatement,";
    }
    yield '}..removeWhere((k, v) => v == null); }';
  }

  Iterable<String> buildToObjectMethod() sync* {
    final mapName = 'data';
    yield '@override $transferClass toObject(Map<String, dynamic> $mapName) { return $transferClass(';
    for (final field in fields) {
      final decodingStatement = field.buildDecodingStatement(mapName);
      if (field.named) {
        yield '${field.name}: $decodingStatement,';
      } else {
        yield '$decodingStatement,';
      }
    }
    yield '); }';
  }
}
