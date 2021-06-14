import 'package:cl_datahub/persistence.dart';

/// Representing query select targets in a uniform, abstract way.
///
/// To allow different [DatabaseAdapter] implementations to interpret or
/// implement selection and aggregation in different ways
/// (e.g. convert to SQL statements).
///
/// See:  [WildcardSelect]
///       [FieldSelect]
///       [AggregateSelect]
abstract class QuerySelect {
  const QuerySelect();

  /// Convenience getter for a count aggregation with alias 'count'.
  static const AggregateSelect count = AggregateSelect(AggregateType.count, 'count');
}

/// Select every available column / field.
///
/// Equivalent to `SELECT *` in SQL.
class WildcardSelect extends QuerySelect {
  const WildcardSelect();
}

/// Select a specific column / field.
class FieldSelect extends QuerySelect {
  final DataField field;

  const FieldSelect(this.field);
}

enum AggregateType { count, min, max, sum, avg }

/// Select the result of an aggregation.
class AggregateSelect extends QuerySelect {
  final AggregateType type;
  final QuerySelect? select;
  final String alias;

  const AggregateSelect(this.type, this.alias, [this.select]);
}

//TODO group by?
