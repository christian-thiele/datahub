import '../dao/data_field.dart';
import '../dao/data_type.dart';

abstract class QueryResult {
  final String layoutName;
  final Map<String, dynamic> data;

  QueryResult(this.layoutName, this.data);

  static Map<String, dynamic> merge(List<QueryResult> results) {
    final map = <String, dynamic>{};
    for (final result in results) {
      map.addAll(result.data);
    }
    return map;
  }

  T getFieldValue<T>(DataField<DataType<T>> field);
}
