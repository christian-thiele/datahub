import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

void main() {
  final fieldX = DataField(FieldType.String, 'fieldX');

  test(
    'Select',
    _test(
      SelectBuilder(TableSelectSource('schema', 'table')),
      'SELECT * FROM schema.table',
    ),
  );

  test(
    'Select filter eq string',
    _test(
      SelectBuilder(TableSelectSource('schema', 'table'))
        ..where(Filter.equals(fieldX, 'valueX')),
      'SELECT * FROM schema.table WHERE "fieldX" = \'valueX\'',
    ),
  );

  test(
    'Select filter eq string caseInsensitive',
    _test(
      SelectBuilder(TableSelectSource('schema', 'table'))
        ..where(PropertyCompare(PropertyCompareType.Equals, fieldX, 'valueX',
            caseSensitive: false)),
      'SELECT * FROM schema.table WHERE LOWER("fieldX") = \'valuex\'',
    ),
  );

  test(
    'Select filter eq string contains',
    _test(
      SelectBuilder(TableSelectSource('schema', 'table'))
        ..where(
            PropertyCompare(PropertyCompareType.Contains, fieldX, 'valueX')),
      'SELECT * FROM schema.table WHERE "fieldX" LIKE \'%valueX%\'',
    ),
  );

  test(
    'Select filter eq string contains caseInsensitive',
    _test(
      SelectBuilder(TableSelectSource('schema', 'table'))
        ..where(PropertyCompare(PropertyCompareType.Contains, fieldX, 'valueX',
            caseSensitive: false)),
      'SELECT * FROM schema.table WHERE "fieldX" ILIKE \'%valueX%\'',
    ),
  );

  test(
    'Select filter eq int',
    _test(
      SelectBuilder(TableSelectSource('schema', 'table'))
        ..where(Filter.equals(fieldX, 20)),
      'SELECT * FROM schema.table WHERE "fieldX" = 20',
    ),
  );

  test(
    'Select filter eq double',
    _test(
      SelectBuilder(TableSelectSource('schema', 'table'))
        ..where(Filter.equals(fieldX, 20.12)),
      'SELECT * FROM schema.table WHERE "fieldX" = 20.12',
    ),
  );
}

dynamic Function() _test(SqlBuilder builder, String sql,
        [Map<String, dynamic> substitutions = const {}]) =>
    () => _expect(builder, sql, substitutions);

void _expect(SqlBuilder builder, String sql,
    [Map<String, dynamic> substitutions = const {}]) {
  final result = builder.buildSql();
  expect(result.a, equals(sql));
  expect(result.b.entries, unorderedEquals(substitutions.entries));
}
