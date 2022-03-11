import 'field_type.dart';

class TransferSuperclassBuilder {
  final String transferClass;
  final String? idFieldName;
  final FieldType? idFieldType;

  TransferSuperclassBuilder(
    this.transferClass, {
    this.idFieldName,
    this.idFieldType,
  }) {
    if (idFieldType is! StringFieldType &&
        idFieldType is! IntFieldType &&
        idFieldType != null) {
      throw Exception('Only String and int are allowed as ID-field types.');
    }
  }

  Iterable<String> build() sync* {
    yield 'abstract class _TransferObject extends TransferObjectBase<${idFieldType?.typeName ?? 'Null'}> {';
    yield '@override dynamic toJson() => ${transferClass}TransferBean.staticToMap(this as $transferClass);';
    yield '@override TransferBean<$transferClass> get bean => ${transferClass}TransferBean();';
    yield* buildIdMethod();
    yield '}';
  }

  Iterable<String> buildIdMethod() sync* {
    if (idFieldName != null && idFieldType != null) {
      yield '${idFieldType!.typeName} get $idFieldName;';
    }
    yield '@override ${idFieldType?.typeName ?? 'Null'} getId() => ${idFieldName ?? 'null'};';
  }
}