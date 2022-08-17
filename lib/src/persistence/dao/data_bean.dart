import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/src/persistence/query/query_result.dart';

abstract class DataBean<TDao> extends QuerySource<TDao> {
  String get layoutName;

  List<DataField> get fields;

  const DataBean();

  Map<String, dynamic> unmap(TDao dao, {bool includePrimaryKey = false});

  @override
  TDao map(List<QueryResult> data);

  /// Create [JoinedQuerySource] where this DataBean is used as main source.
  ///
  /// When [mainField] and [otherField] are null, the only [ForeignKey] of
  /// this is used as [mainField] and the corresponding [PrimaryKey] of [other]
  /// is used as [otherField]. If this bean has multiple [ForeignKey]s to
  /// [other], this throws a [PersistenceException].
  TupleJoinQuerySource<TDao, Tb> join<Tb>(DataBean<Tb> other,
      {DataField? mainField,
      DataField? otherField,
      CompareType type = CompareType.equals}) {
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

    return TupleJoinQuerySource(
        this, BeanJoin(other, mainField, type, otherField));
  }
}

abstract class PrimaryKeyDataBean<TDao, TPrimaryKey> extends DataBean<TDao> {
  PrimaryKey get primaryKeyField;

  const PrimaryKeyDataBean();
}
