import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

import 'package:cl_datahub/src/persistence/postgresql/sql/sql.dart';

void main() {
  final fieldX = DataField(FieldType.String, 'fake', 'fieldX');
  final schemaTable = SelectFromTable('schema', 'table');
  final otherTable = SelectFromTable('schema', 'other');
  final otherTable2 = SelectFromTable('schema', 'different');
  group('TableSelectSource', () {
    test(
      'Select',
      _test(
        SelectBuilder(schemaTable),
        'SELECT * FROM schema.table',
      ),
    );

    test(
      'Select filter eq string',
      _test(
        SelectBuilder(schemaTable)..where(Filter.equals(fieldX, 'valueX')),
        'SELECT * FROM schema.table WHERE "fake"."fieldX" = \'valueX\'',
      ),
    );

    test(
      'Select filter eq string caseInsensitive',
      _test(
        SelectBuilder(schemaTable)
          ..where(PropertyCompare(PropertyCompareType.Equals, fieldX, 'valueX',
              caseSensitive: false)),
        'SELECT * FROM schema.table WHERE LOWER("fake"."fieldX") = \'valuex\'',
      ),
    );

    test(
      'Select filter eq string contains',
      _test(
        SelectBuilder(schemaTable)
          ..where(
              PropertyCompare(PropertyCompareType.Contains, fieldX, 'valueX')),
        'SELECT * FROM schema.table WHERE "fake"."fieldX" LIKE \'%valueX%\'',
      ),
    );

    test(
      'Select filter eq string contains caseInsensitive',
      _test(
        SelectBuilder(schemaTable)
          ..where(PropertyCompare(
              PropertyCompareType.Contains, fieldX, 'valueX',
              caseSensitive: false)),
        'SELECT * FROM schema.table WHERE "fake"."fieldX" ILIKE \'%valueX%\'',
      ),
    );

    test(
      'Select filter eq int',
      _test(
        SelectBuilder(schemaTable)..where(Filter.equals(fieldX, 20)),
        'SELECT * FROM schema.table WHERE "fake"."fieldX" = 20',
      ),
    );

    test(
      'Select filter eq double',
      _test(
        SelectBuilder(schemaTable)..where(Filter.equals(fieldX, 20.12)),
        'SELECT * FROM schema.table WHERE "fake"."fieldX" = 20.12',
      ),
    );
  });

  group('JoinedSelectSource', () {
    test(
      'Join other',
      _test(
        SelectBuilder(
          JoinedSelectFrom(
            schemaTable,
            [
              TableJoin(otherTable, 'id', PropertyCompareType.Equals, 'main_id')
            ],
          ),
        ),
        'SELECT * FROM schema.table JOIN schema.other ON schema.table."id" = schema.other."main_id"',
      ),
    );

    test(
      'Join other filter eq string',
      _test(
        SelectBuilder(
          JoinedSelectFrom(
            schemaTable,
            [
              TableJoin(otherTable, 'id', PropertyCompareType.Equals, 'main_id')
            ],
          ),
        )..where(Filter.equals(fieldX, 'valueX')),
        'SELECT * FROM schema.table JOIN schema.other ON schema.table."id" = '
        'schema.other."main_id" WHERE "fake"."fieldX" = \'valueX\'',
      ),
    );

    test(
      'Join multiple',
      _test(
        SelectBuilder(
          JoinedSelectFrom(
            schemaTable,
            [
              TableJoin(
                  otherTable, 'id', PropertyCompareType.Equals, 'main_id'),
              TableJoin(
                  otherTable2, 'xyz', PropertyCompareType.LessThan, 'abc'),
            ],
          ),
        )..where(PropertyCompare(PropertyCompareType.Equals, fieldX, 'valueX',
            caseSensitive: false)),
        'SELECT * FROM schema.table JOIN schema.other ON schema.table."id" = '
        'schema.other."main_id" JOIN schema.different ON schema.table."xyz" < '
        'schema.different."abc" WHERE LOWER("fake"."fieldX") = \'valuex\'',
      ),
    );
  });
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
