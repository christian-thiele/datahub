import 'package:cl_datahub/persistence.dart';

/// Defining a common base class among query sources.
///
/// A QuerySource is either a [BaseDataBean] or a [JoinedQuerySource]
abstract class QuerySource {}

//TODO use filter objects for join
class BeanJoin {
  final BaseDataBean bean;
  final DataField mainField;
  final CompareType type;
  final DataField beanField;

  BeanJoin(this.bean, this.mainField, this.type, this.beanField);
}

class JoinedQuerySource extends QuerySource {
  final BaseDataBean main;
  final List<BeanJoin> joins;

  JoinedQuerySource(this.main, this.joins);

  /// Create [JoinedQuerySource] with this and the following join.
  ///
  /// This enabled chaining of join() calls.
  JoinedQuerySource join(
      BaseDataBean other, DataField mainField, DataField otherField,
      {CompareType type = CompareType.equals}) {
    return JoinedQuerySource(
      main,
      joins.followedBy([BeanJoin(other, mainField, type, otherField)]).toList(),
    );
  }
}
