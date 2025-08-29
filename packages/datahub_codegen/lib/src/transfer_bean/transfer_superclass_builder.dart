import '../utils/field_type.dart';

class TransferSuperclassBuilder {
  final String transferClass;
  final String? idFieldName;
  final TransferFieldType? idFieldType;

  TransferSuperclassBuilder(
    this.transferClass, {
    this.idFieldName,
    this.idFieldType,
  }) {
    if (idFieldType is! StringFieldType &&
        idFieldType is! IntFieldType &&
        idFieldType != null) {
      throw Exception(
          'Only non-nullable String and int are allowed as ID-field types.');
    }
  }

  Iterable<String> build() sync* {
    yield 'abstract class _TransferObject extends TransferObjectBase<${idFieldType?.typeName ?? 'void'}> {';
    yield '@override dynamic toJson() => ${transferClass}TransferBean.toMap(this as $transferClass);';
    yield '@override TransferBean<$transferClass> get bean => ${transferClass}TransferBean;';
    yield* buildIdMethod();
    yield '}';
  }

  Iterable<String> buildIdMethod() sync* {
    if (idFieldName != null && idFieldType != null) {
      yield '@override ${idFieldType!.typeName} getId() => '
          '(this as $transferClass).${idFieldName ?? 'null'};';
    } else {
      yield '@override void getId() {}';
    }
  }
}
