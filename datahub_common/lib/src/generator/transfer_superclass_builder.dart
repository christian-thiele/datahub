class TransferSuperclassBuilder {
  final String transferClass;

  TransferSuperclassBuilder(this.transferClass);

  Iterable<String> build() sync* {
    yield 'abstract class _TransferObject extends TransferObjectBase {';
    yield '@override dynamic toJson() => ${transferClass}TransferBean.staticToMap(this as $transferClass);';
    yield '@override TransferBean<$transferClass> get bean => ${transferClass}TransferBean();';
    yield '}';
  }
}
