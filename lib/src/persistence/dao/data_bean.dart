import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

abstract class DataBean<TDao> extends QuerySource<TDao> {
  String get layoutName;

  List<DataField> get fields;

  const DataBean();

  Map<DataField, dynamic> unmap(TDao dao, {bool includePrimaryKey = false});

  @override
  TDao? map(List<QueryResult> results) {
    final data =
        results.firstOrNullWhere((r) => r.layoutName == layoutName)?.data;
    if (data == null) {
      return null;
    }
    return mapValues(data);
  }

  TDao mapValues(Map<String, dynamic> data);

  /// Create [JoinedQuerySource] where this DataBean is used as main source.
  ///
  /// This will create an inner join. (Both return types will be non-null)
  ///
  /// When [mainField] and [otherField] are null, the only [ForeignKey] of
  /// this is used as [mainField] and the corresponding [PrimaryKey] of [other]
  /// is used as [otherField]. If this bean has multiple [ForeignKey]s to
  /// [other], this throws a [PersistenceException].
  TupleJoinQuerySource<TDao, Tb> join<Tb>(DataBean<Tb> other,
      {Filter? filter}) {
    if (filter == null) {
      final foreignField = fields
          .whereType<ForeignKey>()
          .firstOrNullWhere((f) => other.fields.contains(f.foreignPrimaryKey));
      final mainField = foreignField;
      final otherField = foreignField?.foreignPrimaryKey;
      filter = mainField?.equals(otherField);
    }

    if (filter == null) {
      throw PersistenceException(
          'Could not autodetect join relation between "$runtimeType" and "${other.runtimeType}".');
    }

    return TupleJoinQuerySource(this, BeanJoin(other, filter));
  }

  /// Create [JoinedQuerySource] where this DataBean is used as main source.
  ///
  /// This will create a left join. (Return value for [other] will be nullable)
  ///
  /// When [mainField] and [otherField] are null, the only [ForeignKey] of
  /// this is used as [mainField] and the corresponding [PrimaryKey] of [other]
  /// is used as [otherField]. If this bean has multiple [ForeignKey]s to
  /// [other], this throws a [PersistenceException].
  TupleJoinQuerySource<TDao, Tb?> leftJoin<Tb>(DataBean<Tb> other,
      {Filter? filter}) {
    if (filter == null) {
      final foreignField = fields
          .whereType<ForeignKey>()
          .firstOrNullWhere((f) => other.fields.contains(f.foreignPrimaryKey));
      final mainField = foreignField;
      final otherField = foreignField?.foreignPrimaryKey;
      filter = mainField?.equals(otherField);
    }

    if (filter == null) {
      throw PersistenceException(
          'Could not autodetect join relation between "$runtimeType" and "${other.runtimeType}".');
    }

    return TupleJoinQuerySource<TDao, Tb?>(this, BeanJoin(other, filter));
  }
}

abstract class PrimaryKeyDataBean<TDao, TPrimaryKey> extends DataBean<TDao> {
  PrimaryKey get primaryKey;

  const PrimaryKeyDataBean();
}
