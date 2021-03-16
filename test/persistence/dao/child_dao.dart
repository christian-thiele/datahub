import 'package:cl_datahub/persistence.dart';

import 'example_dao.dart';

class ChildDao extends DataObject {
  @PrimaryKey()
  final int id;

  @ForeignKey(ExampleDao)
  final int exampleId;

  final ParentProxy<ExampleDao> example;

  final String whatever;
  final double howMuchOfWhatever;

  ChildDao(this.id, this.exampleId, this.example, this.whatever,
      this.howMuchOfWhatever)
      : super('children');
}
