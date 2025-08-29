// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dao.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension UserDaoCopyExtension on UserDao {
  UserDao copyWith({
    int? id,
    String? name,
    int? executionId,
    Uint8List? image,
  }) {
    return UserDao(
      id: id ?? this.id,
      name: name ?? this.name,
      executionId: executionId ?? this.executionId,
      image: image ?? this.image,
    );
  }
}

// **************************************************************************
// DataBeanGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names

final UserDaoDataBean = _UserDaoDataBeanImpl._();

class _UserDaoDataBeanImpl extends PrimaryKeyDataBean<UserDao, int> {
  @override
  final layoutName = 'user';

  @override
  PrimaryKey get primaryKey => id;

  _UserDaoDataBeanImpl._();

  final id = PrimaryKey<IntDataType>(
    layoutName: 'user',
    name: 'id',
    length: 0,
    autoIncrement: true,
  );

  final name = DataField<StringDataType>(
    layoutName: 'user',
    name: 'username',
    nullable: false,
    length: 128,
  );

  final executionId = DataField<IntDataType>(
    layoutName: 'user',
    name: 'execution_id',
    nullable: false,
    length: 0,
  );

  final image = DataField<ByteDataType>(
    layoutName: 'user',
    name: 'image',
    nullable: false,
    length: 0,
  );

  @override
  late final fields = [
    id,
    name,
    executionId,
    image,
  ];

  @override
  late final reactivePartitions = [
    id,
  ];

  @override
  Map<DataField, dynamic> unmap(UserDao dao, {bool includePrimaryKey = false}) {
    return {
      if (includePrimaryKey) id: dao.id,
      name: dao.name,
      executionId: dao.executionId,
      image: dao.image,
    };
  }

  @override
  UserDao mapValues(Map<String, dynamic> data) {
    return UserDao(
      id: data['id'],
      name: data['username'],
      executionId: data['execution_id'],
      image: data['image'],
    );
  }
}

// **************************************************************************
// DataSuperclassGenerator
// **************************************************************************

abstract class _Dao extends PrimaryKeyDao<UserDao, int> {
  @override
  _UserDaoDataBeanImpl get bean => UserDaoDataBean;

  @override
  int getPrimaryKey() => (this as UserDao).id;

  @override
  UserDao copyWithPrimaryKey(int value) =>
      (this as UserDao).copyWith(id: value);
}
