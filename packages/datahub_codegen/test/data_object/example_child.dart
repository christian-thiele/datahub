import 'package:datahub/datahub.dart';

import 'example.dart';

part 'example_child.g.dart';

@DaoType(namingConvention: NamingConvention.camelCase)
class ExampleChild extends _Dao {
  @PrimaryKeyDaoField()
  final int id;
  final String name;

  @ReactivePartition()
  @ForeignKeyDaoField(Example)
  final int parentExample;

  ExampleChild(
      {required this.id, required this.name, required this.parentExample});
}
