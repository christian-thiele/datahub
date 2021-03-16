import 'package:cl_datahub/persistence.dart';

import 'child_dao.dart';

class ExampleDao extends DataObject {
  @PrimaryKey()
  final int id;
  final String text1;
  final String text2;
  final int howMany;
  final double someNumber;
  final bool isThatSo;

  final ProxySet<ChildDao> children;

  ExampleDao(this.id, this.text1, this.text2, this.howMany, this.someNumber,
      this.isThatSo, this.children)
      : super('eXaMpLeS');
}