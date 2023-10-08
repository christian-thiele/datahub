import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

/// Defining a common base class among query sources.
///
/// A QuerySource is either a [BaseDataBean], a [JoinedQuerySource] or a [SubQuery].
abstract class QuerySource<T> {
  const QuerySource();

  T? map(List<QueryResult> results);
}

class BeanJoin<TDao> {
  final DataBean<TDao> bean;
  final Filter filter;

  BeanJoin(this.bean, this.filter);

  BeanJoin.foreignKey(this.bean, DataField mainField, DataField beanField)
      : filter = mainField.equals(beanField);
}

abstract class JoinedQuerySource {
  DataBean get main;

  bool get innerJoin;

  List<BeanJoin> get joins;
}

class TupleJoinQuerySource<Ta, Tb> extends QuerySource<Tuple<Ta, Tb>>
    implements JoinedQuerySource {
  @override
  final DataBean<Ta> main;
  final BeanJoin<Tb> joinB;

  @override
  final innerJoin = !TypeCheck<Null>().isSubtypeOf<Tb>();

  @override
  List<BeanJoin> get joins => [joinB];

  TupleJoinQuerySource(this.main, this.joinB);

  @override
  Tuple<Ta, Tb> map(List<QueryResult> results) {
    final mainResult = main.map(results);
    if (mainResult == null) {
      throw PersistenceException.internal(
          'MainResult of TupleJoinQuerySource is null.');
    }

    final resultB = joinB.bean.map(results);
    if (innerJoin && resultB == null) {
      throw PersistenceException.internal(
          'ResultB of TupleJoinQuerySource is null but innerJoin == true.');
    }

    return Tuple(mainResult, resultB as Tb);
  }

  /// Create [JoinedQuerySource] with this and the following join.
  ///
  /// This enabled chaining of join() calls.
  TripleJoinQuerySource<Ta, Tb, Tc> join<Tc, TDao extends Tc>(
      DataBean<TDao> other, Filter filter) {
    return TripleJoinQuerySource<Ta, Tb, Tc>(
      main,
      joinB,
      BeanJoin<TDao>(other, filter),
    );
  }
}

class TripleJoinQuerySource<Ta, Tb, Tc> extends QuerySource<Triple<Ta, Tb, Tc>>
    implements JoinedQuerySource {
  @override
  final DataBean<Ta> main;
  final BeanJoin<Tb> joinB;
  final BeanJoin<Tc> joinC;

  @override
  final innerJoin = !TypeCheck<Null>().isSubtypeOf<Tb>() &&
      !TypeCheck<Null>().isSubtypeOf<Tc>();

  @override
  List<BeanJoin> get joins => [joinB, joinC];

  TripleJoinQuerySource(this.main, this.joinB, this.joinC);

  @override
  Triple<Ta, Tb, Tc> map(List<QueryResult> results) {
    final mainResult = main.map(results);
    if (mainResult == null) {
      throw PersistenceException.internal(
          'MainResult of TripleJoinQuerySource is null.');
    }

    final resultB = joinB.bean.map(results);
    if (innerJoin && resultB == null) {
      throw PersistenceException.internal(
          'ResultB of TripleJoinQuerySource is null but innerJoin == true.');
    }

    final resultC = joinC.bean.map(results);
    if (innerJoin && resultC == null) {
      throw PersistenceException.internal(
          'ResultC of TripleJoinQuerySource is null but innerJoin == true.');
    }

    return Triple(
      mainResult,
      resultB as Tb,
      resultC as Tc,
    );
  }
}
