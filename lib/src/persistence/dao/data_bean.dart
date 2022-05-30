import 'package:cl_datahub/persistence.dart';

abstract class BaseDataBean implements QuerySource {
  String get layoutName;
  List<DataField> get fields;

  const BaseDataBean();

  /// Create [JoinedQuerySource] where this DataBean is used as main source.
  JoinedQuerySource join(
      BaseDataBean other, DataField mainField, DataField otherField,
      {PropertyCompareType type = PropertyCompareType.Equals}) {
    return JoinedQuerySource(
        this, [BeanJoin(other, mainField, type, otherField)]);
  }
}

abstract class PrimaryKeyDataBean<TPrimaryKey> extends BaseDataBean {
  PrimaryKey get primaryKeyField;
}

abstract class DaoDataBean<TDao> extends BaseDataBean {
  const DaoDataBean();

  Map<String, dynamic> unmap(TDao dao, {bool includePrimaryKey = false});

  TDao map(Map<String, dynamic> data);
}

abstract class PKDaoDataBean<TDao, TPrimaryKey> extends DaoDataBean<TDao>
    implements PrimaryKeyDataBean<TPrimaryKey> {
  const PKDaoDataBean();
}
