import 'transfer_field.dart';

class TransferBeanBuilder {
  final String transferClass;
  final List<TransferField> fields;

  TransferBeanBuilder(this.transferClass, this.fields);

  Iterable<String> build() sync* {
    yield 'class ${transferClass}TransferBean extends TransferBean<$transferClass> {';
    yield* buildConstConstructor();
    yield* buildToMapMethod();
    yield* buildToObjectMethod();
    yield '}';
  }

  Iterable<String> buildConstConstructor() sync* {
    yield 'const ${transferClass}TransferBean();';
  }

  Iterable<String> buildToMapMethod() sync* {
    final objectName = 'transferObject';
    yield '@override Map<String, dynamic> toMap($transferClass $objectName) => staticToMap($objectName);';
    yield 'static Map<String, dynamic> staticToMap($transferClass $objectName) { return {';
    for (final field in fields) {
      final encodingStatement = field.buildEncodingStatement(objectName);
      yield "'${field.key}': $encodingStatement,";
    }
    yield '}; }';
  }

  Iterable<String> buildToObjectMethod() sync* {
    final mapName = 'data';
    yield '@override $transferClass toObject(Map<String, dynamic> $mapName) => staticToObject($mapName);';
    yield 'static $transferClass staticToObject(Map<String, dynamic> $mapName) { return $transferClass(';
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
