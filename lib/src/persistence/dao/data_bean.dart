import 'package:boost/boost.dart';
import 'package:cl_datahub/persistence.dart';

abstract class BaseDataBean implements QuerySource {
  String get layoutName;

  List<DataField> get fields;

  const BaseDataBean();

  /// Create [JoinedQuerySource] where this DataBean is used as main source.
  ///
  /// When [mainField] and [otherField] are null, the only [ForeignKey] of
  /// this is used as [mainField] and the corresponding [PrimaryKey] of [other]
  /// is used as [otherField]. If this bean has multiple [ForeignKey]s to
  /// [other], this throws a [PersistenceException].
  JoinedQuerySource join(BaseDataBean other,
      {DataField? mainField,
      DataField? otherField,
      PropertyCompareType type = PropertyCompareType.Equals}) {
    if ((mainField == null) != (otherField == null)) {
      throw PersistenceException(
          'mainField and otherField must be either both null or both non-null.');
    }

    if (mainField == null && otherField == null) {
      final foreignField = fields
          .whereType<ForeignKey>()
          .firstOrNullWhere((f) => other.fields.contains(f.foreignPrimaryKey));
      mainField = foreignField;
      otherField = foreignField?.foreignPrimaryKey;
    }

    if (mainField == null || otherField == null) {
      throw PersistenceException(
          'Could not autodetect join relation between "$runtimeType" and "${other.runtimeType}".');
    }

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
