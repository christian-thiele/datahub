import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

/// Defining a common base class among query sources.
///
/// A QuerySource is either a [BaseDataBean] or a [JoinedQuerySource]
abstract class QuerySource<T> {
  const QuerySource();

  T map(List<QueryResult> results);
}

//TODO use filter objects for join
class BeanJoin<TDao> {
  final DataBean<TDao> bean;
  final DataField mainField;
  final CompareType type;
  final DataField beanField;

  BeanJoin(this.bean, this.mainField, this.type, this.beanField);
}

abstract class JoinedQuerySource {
  DataBean get main;

  List<BeanJoin> get joins;
}

class TupleJoinQuerySource<Ta, Tb> extends QuerySource<Tuple<Ta, Tb>>
    implements JoinedQuerySource {
  @override
  final DataBean<Ta> main;
  final BeanJoin<Tb> joinB;

  @override
  List<BeanJoin> get joins => [joinB];

  TupleJoinQuerySource(this.main, this.joinB);

  @override
  Tuple<Ta, Tb> map(List<QueryResult> results) {
    return Tuple(main.map(results), joinB.bean.map(results));
  }

  /// Create [JoinedQuerySource] with this and the following join.
  ///
  /// This enabled chaining of join() calls.
  TripleJoinQuerySource<Ta, Tb, TDao> join<TDao>(
      DataBean<TDao> other, DataField mainField, DataField otherField,
      {CompareType type = CompareType.equals}) {
    return TripleJoinQuerySource(
      main,
      joinB,
      BeanJoin<TDao>(other, mainField, type, otherField),
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
  List<BeanJoin> get joins => [joinB, joinC];

  TripleJoinQuerySource(this.main, this.joinB, this.joinC);

  @override
  Triple<Ta, Tb, Tc> map(List<QueryResult> results) {
    return Triple(
      main.map(results),
      joinB.bean.map(results),
      joinC.bean.map(results),
    );
  }
}
