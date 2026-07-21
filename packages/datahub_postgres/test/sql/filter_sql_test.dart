import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:test/test.dart';

import '../data/arrays_data.dart';
import '../data/example_enum.dart';

void main() {
  test('Array Comparators: contains', () {
    expect(
      _fl($ArraysData.bean, $ArraysData.$stringArray.contains('my-string')),
      ''''my-string' = ANY("arrays_data"."string_array")''',
    );
    expect(
      _fl($ArraysData.bean, $ArraysData.$intArray.contains(5)),
      '''5 = ANY("arrays_data"."int_array")''',
    );
    expect(
      _fl($ArraysData.bean, $ArraysData.$doubleArray.contains(7.3)),
      '''7.3 = ANY("arrays_data"."double_array")''',
    );
    expect(
      _fl($ArraysData.bean, $ArraysData.$boolArray.contains(true)),
      '''true = ANY("arrays_data"."bool_array")''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        $ArraysData.$enumArray.contains(ExampleEnum.something),
      ),
      ''''something' = ANY("arrays_data"."enum_array")''',
    );
  });

  test('Array Comparators: isIn', () {
    expect(
      _fl(
        $ArraysData.bean,
        ValueExpression('my-string').isIn($ArraysData.$stringArray),
      ),
      ''''my-string' = ANY("arrays_data"."string_array")''',
    );
    expect(
      _fl($ArraysData.bean, ValueExpression(5).isIn($ArraysData.$intArray)),
      '''5 = ANY("arrays_data"."int_array")''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        ValueExpression(7.3).isIn($ArraysData.$doubleArray),
      ),
      '''7.3 = ANY("arrays_data"."double_array")''',
    );
    expect(
      _fl($ArraysData.bean, ValueExpression(true).isIn($ArraysData.$boolArray)),
      '''true = ANY("arrays_data"."bool_array")''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        ValueExpression('something').isIn($ArraysData.$enumArray),
      ),
      ''''something' = ANY("arrays_data"."enum_array")''',
    );
  });

  test('JSON Comparators: contains', () {
    expect(
      _fl(
        $ArraysData.bean,
        $ArraysData.$jsonList.contains([
          {'prop': 'val'},
        ]),
      ),
      '''"arrays_data"."json_list" @> '[{"prop":"val"}]'::jsonb''',
    );
    expect(
      _fl($ArraysData.bean, $ArraysData.$jsonList.contains({'prop': 'val'})),
      '''"arrays_data"."json_list" @> '{"prop":"val"}'::jsonb''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        $ArraysData.$jsonList.contains(<dynamic>['something']),
      ),
      '''"arrays_data"."json_list" @> '["something"]'::jsonb''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        $ArraysData.$jsonList.contains(<String>['something']),
      ),
      '''"arrays_data"."json_list" @> array_to_json('{"something"}'::text[])::jsonb''',
    );
    expect(
      _fl($ArraysData.bean, $ArraysData.$jsonMap.contains({'prop': 'val'})),
      '''"arrays_data"."json_map" @> '{"prop":"val"}'::jsonb''',
    );
  });

  test('JSON Comparators: isIn', () {
    expect(
      _fl(
        $ArraysData.bean,
        ValueExpression([
          {'prop': 'val'},
        ]).isIn($ArraysData.$jsonList),
      ),
      '''"arrays_data"."json_list" @> '[{"prop":"val"}]'::jsonb''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        ValueExpression({'prop': 'val'}).isIn($ArraysData.$jsonList),
      ),
      '''"arrays_data"."json_list" @> '{"prop":"val"}'::jsonb''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        ValueExpression({'prop': 'val'}).isIn($ArraysData.$jsonMap),
      ),
      '''"arrays_data"."json_map" @> '{"prop":"val"}'::jsonb''',
    );
    expect(
      _fl(
        $ArraysData.bean,
        ValueExpression([123, 456]).isIn($ArraysData.$jsonMap),
      ),
      '''"arrays_data"."json_map" @> array_to_json('{123,456}'::int[])::jsonb''',
    );
  });
}

String? _fl<T extends DataObject>(DataBean<T> bean, Filter filter) =>
    _f(bean, filter)?.toLiteralString();

Sql? _f<T extends DataObject>(DataBean<T> bean, Filter filter) {
  final table = PostgresqlDataTable<T>(
    bean: bean,
    schemaName: 'public',
    name: toNamingConvention(bean.name, NamingConvention.lowerSnakeCase),
  );

  return buildFilterSql(
    filter,
    table.attributes.map((a) => (a, table.relation)),
  );
}
