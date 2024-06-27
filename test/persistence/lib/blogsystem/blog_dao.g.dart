// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_dao.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension BlogDaoCopyExtension on BlogDao {
  BlogDao copyWith({
    String? key,
    int? ownerId,
    String? displayName,
    bool? enabled,
  }) {
    return BlogDao(
      key ?? this.key,
      ownerId ?? this.ownerId,
      displayName: displayName ?? this.displayName,
      enabled: enabled ?? this.enabled,
    );
  }
}

// **************************************************************************
// DataBeanGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names

final BlogDaoDataBean = _BlogDaoDataBeanImpl._();

class _BlogDaoDataBeanImpl extends PrimaryKeyDataBean<BlogDao, String> {
  @override
  final layoutName = 'blog';

  @override
  PrimaryKey get primaryKey => key;

  _BlogDaoDataBeanImpl._();

  final key = PrimaryKey<StringDataType>(
    layoutName: 'blog',
    name: 'key',
    length: 0,
    autoIncrement: true,
  );

  final ownerId = ForeignKey<IntDataType>(
    foreignPrimaryKey: UserDaoDataBean.id,
    layoutName: 'blog',
    name: 'owner_id',
    nullable: false,
  );

  final displayName = DataField<StringDataType>(
    layoutName: 'blog',
    name: 'display_name',
    nullable: false,
    length: 0,
  );

  final enabled = DataField<BoolDataType>(
    layoutName: 'blog',
    name: 'enabled',
    nullable: false,
    length: 0,
  );

  @override
  late final fields = [
    key,
    ownerId,
    displayName,
    enabled,
  ];

  @override
  Map<DataField, dynamic> unmap(BlogDao dao, {bool includePrimaryKey = false}) {
    return {
      if (includePrimaryKey) key: dao.key,
      ownerId: dao.ownerId,
      displayName: dao.displayName,
      enabled: dao.enabled,
    };
  }

  @override
  BlogDao mapValues(Map<String, dynamic> data) {
    return BlogDao(
      data['key'],
      data['owner_id'],
      displayName: data['display_name'],
      enabled: data['enabled'],
    );
  }
}

// **************************************************************************
// DataSuperclassGenerator
// **************************************************************************

abstract class _Dao extends PrimaryKeyDao<BlogDao, String> {
  @override
  _BlogDaoDataBeanImpl get bean => BlogDaoDataBean;

  @override
  String getPrimaryKey() => (this as BlogDao).key;

  @override
  BlogDao copyWithPrimaryKey(String value) =>
      (this as BlogDao).copyWith(key: value);
}
