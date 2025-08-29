// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension ExampleCopyExtension on Example {
  Example copyWith({
    int? id,
    String? name,
    String? abbreviation,
    DateTime? createTimestamp,
    int? someNumber,
    double? someExactNumber,
    bool? isActive,
    List<String>? tags,
    ExampleEnum? someEnum,
    List<ExampleEnum>? someEnums,
    ExampleEnum? nullableEnum,
    bool nullNullableEnum = false,
  }) {
    return Example(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      createTimestamp: createTimestamp ?? this.createTimestamp,
      someNumber: someNumber ?? this.someNumber,
      someExactNumber: someExactNumber ?? this.someExactNumber,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      someEnum: someEnum ?? this.someEnum,
      someEnums: someEnums ?? this.someEnums,
      nullableEnum:
          nullNullableEnum ? null : (nullableEnum ?? this.nullableEnum),
    );
  }
}

// **************************************************************************
// DataBeanGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names

final ExampleDataBean = _ExampleDataBeanImpl._();

class _ExampleDataBeanImpl extends PrimaryKeyDataBean<Example, int> {
  @override
  final layoutName = 'Example';

  @override
  PrimaryKey get primaryKey => id;

  _ExampleDataBeanImpl._();

  final id = PrimaryKey<IntDataType>(
    layoutName: 'Example',
    name: 'Id',
    length: 0,
    autoIncrement: true,
  );

  final name = DataField<StringDataType>(
    layoutName: 'Example',
    name: 'Name',
    nullable: false,
    length: 0,
  );

  final abbreviation = DataField<StringDataType>(
    layoutName: 'Example',
    name: 'Abbreviation',
    nullable: false,
    length: 8,
  );

  final createTimestamp = DataField<DateTimeDataType>(
    layoutName: 'Example',
    name: 'signup_timestamp',
    nullable: false,
    length: 0,
  );

  final someNumber = DataField<IntDataType>(
    layoutName: 'Example',
    name: 'SomeNumber',
    nullable: false,
    length: 0,
  );

  final someExactNumber = DataField<DoubleDataType>(
    layoutName: 'Example',
    name: 'SomeExactNumber',
    nullable: false,
    length: 0,
  );

  final isActive = DataField<BoolDataType>(
    layoutName: 'Example',
    name: 'IsActive',
    nullable: false,
    length: 0,
  );

  final tags = DataField<StringArrayDataType>(
    layoutName: 'Example',
    name: 'Tags',
    nullable: false,
    length: 0,
  );

  final someEnum = DataField<StringDataType>(
    layoutName: 'Example',
    name: 'SomeEnum',
    nullable: false,
    length: 0,
  );

  final someEnums = DataField<StringArrayDataType>(
    layoutName: 'Example',
    name: 'SomeEnums',
    nullable: false,
    length: 0,
  );

  final nullableEnum = DataField<StringDataType>(
    layoutName: 'Example',
    name: 'NullableEnum',
    nullable: true,
    length: 0,
  );

  @override
  late final fields = [
    id,
    name,
    abbreviation,
    createTimestamp,
    someNumber,
    someExactNumber,
    isActive,
    tags,
    someEnum,
    someEnums,
    nullableEnum,
  ];

  @override
  late final reactivePartitions = [
    id,
  ];

  @override
  Map<DataField, dynamic> unmap(Example dao, {bool includePrimaryKey = false}) {
    return {
      if (includePrimaryKey) id: dao.id,
      name: dao.name,
      abbreviation: dao.abbreviation,
      createTimestamp: dao.createTimestamp,
      someNumber: dao.someNumber,
      someExactNumber: dao.someExactNumber,
      isActive: dao.isActive,
      tags: dao.tags,
      someEnum: dao.someEnum.name,
      someEnums: dao.someEnums,
      nullableEnum: dao.nullableEnum?.name,
    };
  }

  @override
  Example mapValues(Map<String, dynamic> data) {
    return Example(
      id: data['Id'],
      name: data['Name'],
      abbreviation: data['Abbreviation'],
      createTimestamp: data['signup_timestamp'],
      someNumber: data['SomeNumber'],
      someExactNumber: data['SomeExactNumber'],
      isActive: data['IsActive'],
      tags: decodeListTyped<List<String>, String>(data['Tags']),
      someEnum:
          ExampleEnum.values.firstWhere((v) => v.name == (data['SomeEnum'])),
      someEnums: decodeList<List<ExampleEnum>, ExampleEnum>(data['SomeEnums'],
          (v, n) => ExampleEnum.values.firstWhere((e) => e.name == v)),
      nullableEnum: ExampleEnum.values.cast<ExampleEnum?>().firstWhere(
          (v) => v?.name == (data['NullableEnum']),
          orElse: () => null),
    );
  }
}

// **************************************************************************
// DataSuperclassGenerator
// **************************************************************************

abstract class _Dao extends PrimaryKeyDao<Example, int> {
  @override
  _ExampleDataBeanImpl get bean => ExampleDataBean;

  @override
  int getPrimaryKey() => (this as Example).id;

  @override
  Example copyWithPrimaryKey(int value) =>
      (this as Example).copyWith(id: value);
}
