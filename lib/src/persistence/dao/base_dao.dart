import 'package:cl_datahub/cl_datahub.dart';

abstract class BaseDao<TDao> {
  DaoDataBean<TDao> get bean;
}

abstract class PKBaseDao<TDao, TPrimaryKey> extends BaseDao<TDao> {
  @override
  PKDaoDataBean<TDao, TPrimaryKey> get bean;

  TPrimaryKey getPrimaryKey();
}
