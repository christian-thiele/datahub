// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_child.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension ExampleChildCopyExtension on ExampleChild {
  ExampleChild copyWith({
    int? id,
    String? name,
    int? parentExample,
  }) {
    return ExampleChild(
      id: id ?? this.id,
      name: name ?? this.name,
      parentExample: parentExample ?? this.parentExample,
    );
  }
}

// **************************************************************************
// DataBeanGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names

final ExampleChildDataBean = _ExampleChildDataBeanImpl._();

class _ExampleChildDataBeanImpl extends PrimaryKeyDataBean<ExampleChild, int> {
  @override
  final layoutName = 'ExampleChild';

  @override
  PrimaryKey get primaryKey => id;

  _ExampleChildDataBeanImpl._();

  final id = PrimaryKey<IntDataType>(
    layoutName: 'ExampleChild',
    name: 'Id',
    length: 0,
    autoIncrement: true,
  );

  final name = DataField<StringDataType>(
    layoutName: 'ExampleChild',
    name: 'Name',
    nullable: false,
    length: 0,
  );

  final parentExample = ForeignKey<IntDataType>(
    foreignPrimaryKey: ExampleDataBean.id,
    layoutName: 'ExampleChild',
    name: 'ParentExample',
    nullable: false,
  );

  @override
  late final fields = [
    id,
    name,
    parentExample,
  ];

  @override
  late final reactivePartitions = [
    id,
    parentExample,
  ];

  @override
  Map<DataField, dynamic> unmap(ExampleChild dao,
      {bool includePrimaryKey = false}) {
    return {
      if (includePrimaryKey) id: dao.id,
      name: dao.name,
      parentExample: dao.parentExample,
    };
  }

  @override
  ExampleChild mapValues(Map<String, dynamic> data) {
    return ExampleChild(
      id: data['Id'],
      name: data['Name'],
      parentExample: data['ParentExample'],
    );
  }
}

// **************************************************************************
// DataSuperclassGenerator
// **************************************************************************

abstract class _Dao extends PrimaryKeyDao<ExampleChild, int> {
  @override
  _ExampleChildDataBeanImpl get bean => ExampleChildDataBean;

  @override
  int getPrimaryKey() => (this as ExampleChild).id;

  @override
  ExampleChild copyWithPrimaryKey(int value) =>
      (this as ExampleChild).copyWith(id: value);
}
