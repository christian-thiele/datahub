// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_dao.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension ArticleDaoCopyExtension on ArticleDao {
  ArticleDao copyWith({
    int? id,
    int? userId,
    String? blogKey,
    String? title,
    String? content,
    Uint8List? image,
    DateTime? createdTimestamp,
    DateTime? lastEditTimestamp,
  }) {
    return ArticleDao(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      blogKey: blogKey ?? this.blogKey,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastEditTimestamp: lastEditTimestamp ?? this.lastEditTimestamp,
    );
  }
}

// **************************************************************************
// DataBeanGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names

final ArticleDaoDataBean = _ArticleDaoDataBeanImpl._();

class _ArticleDaoDataBeanImpl extends PrimaryKeyDataBean<ArticleDao, int> {
  @override
  final layoutName = 'article';

  @override
  PrimaryKey get primaryKey => id;

  _ArticleDaoDataBeanImpl._();

  final id = PrimaryKey<IntDataType>(
    layoutName: 'article',
    name: 'id',
    length: 0,
    autoIncrement: true,
  );

  final userId = ForeignKey<IntDataType>(
    foreignPrimaryKey: UserDaoDataBean.id,
    layoutName: 'article',
    name: 'user_id',
    nullable: false,
  );

  final blogKey = ForeignKey<StringDataType>(
    foreignPrimaryKey: BlogDaoDataBean.key,
    layoutName: 'article',
    name: 'blog_key',
    nullable: false,
  );

  final title = DataField<StringDataType>(
    layoutName: 'article',
    name: 'title',
    nullable: false,
    length: 0,
  );

  final content = DataField<StringDataType>(
    layoutName: 'article',
    name: 'content',
    nullable: false,
    length: 0,
  );

  final image = DataField<ByteDataType>(
    layoutName: 'article',
    name: 'image',
    nullable: false,
    length: 0,
  );

  final createdTimestamp = DataField<DateTimeDataType>(
    layoutName: 'article',
    name: 'created_timestamp',
    nullable: false,
    length: 0,
  );

  final lastEditTimestamp = DataField<DateTimeDataType>(
    layoutName: 'article',
    name: 'last_edit_timestamp',
    nullable: false,
    length: 0,
  );

  @override
  late final fields = [
    id,
    userId,
    blogKey,
    title,
    content,
    image,
    createdTimestamp,
    lastEditTimestamp,
  ];

  @override
  late final reactivePartitions = [
    id,
  ];

  @override
  Map<DataField, dynamic> unmap(ArticleDao dao,
      {bool includePrimaryKey = false}) {
    return {
      if (includePrimaryKey) id: dao.id,
      userId: dao.userId,
      blogKey: dao.blogKey,
      title: dao.title,
      content: dao.content,
      image: dao.image,
      createdTimestamp: dao.createdTimestamp,
      lastEditTimestamp: dao.lastEditTimestamp,
    };
  }

  @override
  ArticleDao mapValues(Map<String, dynamic> data) {
    return ArticleDao(
      id: data['id'],
      userId: data['user_id'],
      blogKey: data['blog_key'],
      title: data['title'],
      content: data['content'],
      image: data['image'],
      createdTimestamp: data['created_timestamp'],
      lastEditTimestamp: data['last_edit_timestamp'],
    );
  }
}

// **************************************************************************
// DataSuperclassGenerator
// **************************************************************************

abstract class _Dao extends PrimaryKeyDao<ArticleDao, int> {
  @override
  _ArticleDaoDataBeanImpl get bean => ArticleDaoDataBean;

  @override
  int getPrimaryKey() => (this as ArticleDao).id;

  @override
  ArticleDao copyWithPrimaryKey(int value) =>
      (this as ArticleDao).copyWith(id: value);
}
