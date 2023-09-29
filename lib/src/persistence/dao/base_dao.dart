import 'data_bean.dart';

abstract class BaseDao<TDao> {
  DataBean<TDao> get bean;
}

abstract class PrimaryKeyDao<TDao, TPrimaryKey> extends BaseDao<TDao> {
  @override
  PrimaryKeyDataBean<TDao, TPrimaryKey> get bean;

  TPrimaryKey getPrimaryKey();
}
