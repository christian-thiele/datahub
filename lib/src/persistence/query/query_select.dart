import 'package:datahub/persistence.dart';

/// Representing query select targets in a uniform, abstract way.
///
/// To allow different [DatabaseAdapter] implementations to interpret or
/// implement selection and aggregation in different ways
/// (e.g. convert to SQL statements).
///
/// See:  [WildcardSelect]
///       [DataField]
///       [AggregateSelect]
abstract class QuerySelect {
  const QuerySelect();

  /// Convenience getter for a count aggregation with alias 'count'.
  static const AggregateSelect count =
      AggregateSelect(AggregateType.count, 'count');
}

/// Select every available column / field.
///
/// If a DataBean is provided, only fields of this DataBean are selected.
/// This is useful when using joins.
///
/// If no DataBean is given, this equals `SELECT *` in SQL.
class WildcardSelect extends QuerySelect {
  final BaseDataBean? bean;

  const WildcardSelect({this.bean});
}

/// Select a specific column / field.
class FieldSelect extends QuerySelect {
  final DataField field;
  final String? alias;

  const FieldSelect(this.field, {this.alias});
}

enum AggregateType { count, min, max, sum, avg }

/// Select the result of an aggregation.
class AggregateSelect extends QuerySelect {
  final AggregateType type;
  final QuerySelect? select;
  final String alias;

  const AggregateSelect(this.type, this.alias, [this.select]);
}

class ExpressionSelect extends QuerySelect {
  final Expression expression;
  final String alias;

  const ExpressionSelect(this.expression, this.alias);
}

//TODO group by?
