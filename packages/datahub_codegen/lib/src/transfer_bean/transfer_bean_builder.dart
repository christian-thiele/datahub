import 'transfer_field.dart';

class TransferBeanBuilder {
  final String transferClass;
  final List<TransferField> fields;

  TransferBeanBuilder(this.transferClass, this.fields);

  Iterable<String> build() sync* {
    yield '// ignore_for_file: constant_identifier_names';
    yield 'final ${transferClass}TransferBean = _${transferClass}TransferBeanImpl._();';
    yield 'class _${transferClass}TransferBeanImpl extends TransferBean<$transferClass> {';
    yield* buildConstructor();
    yield* buildToMapMethod();
    yield* buildToObjectMethod();
    yield '}';
  }

  Iterable<String> buildConstructor() sync* {
    yield '_${transferClass}TransferBeanImpl._();';
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
    yield '@override $transferClass toObject(Map<String, dynamic> $mapName, {String? name}) { return $transferClass(';
    for (final field in fields) {
      final decodingStatement = field.buildDecodingStatement(mapName, 'name');
      if (field.named) {
        yield '${field.name}: $decodingStatement,';
      } else {
        yield '$decodingStatement,';
      }
    }
    yield '); }';
  }
}
