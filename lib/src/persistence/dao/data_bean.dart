import 'data_field.dart';

abstract class BaseDataBean {
  String get layoutName;
  List<DataField> get fields;
}

abstract class PrimaryKeyDataBean<TPrimaryKey> implements BaseDataBean {
  PrimaryKey get primaryKeyField;
}

abstract class DaoDataBean<TDao> implements BaseDataBean {
  const DaoDataBean();

  Map<String, dynamic> unmap(TDao dao, {bool includePrimaryKey = false});
  TDao map(Map<String, dynamic> data);
}

abstract class PKDaoDataBean<TDao, TPrimaryKey> extends DaoDataBean<TDao>
    implements PrimaryKeyDataBean<TPrimaryKey> {
  const PKDaoDataBean();
}
