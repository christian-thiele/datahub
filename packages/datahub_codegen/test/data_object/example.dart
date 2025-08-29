import 'package:datahub/datahub.dart';

import 'example_enum.dart';

part 'example.g.dart';

@DaoType(namingConvention: NamingConvention.camelCase)
class Example extends _Dao {
  @PrimaryKeyDaoField(type: IntDataType)
  final int id;
  final String name;
  @DaoField(type: StringDataType, length: 8)
  final String abbreviation;
  @DaoField(name: 'signup_timestamp')
  final DateTime createTimestamp;
  final int someNumber;
  final double someExactNumber;
  final bool isActive;
  final List<String> tags;
  final ExampleEnum someEnum;
  final List<ExampleEnum> someEnums;
  final ExampleEnum? nullableEnum;

  Example({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.createTimestamp,
    required this.someNumber,
    required this.someExactNumber,
    required this.isActive,
    required this.tags,
    required this.someEnum,
    required this.someEnums,
    required this.nullableEnum,
  });
}
