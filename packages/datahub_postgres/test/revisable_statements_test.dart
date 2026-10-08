import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/src/data/revisable/revisable_layout.dart';
import 'package:datahub_postgres/src/data/revisable/revisable_statements.dart';
import 'package:test/test.dart';

import 'data/city.dart';

DataField<City, T> _field<T>(String name, {List<MetaData> meta = const []}) =>
    DataField<City, T>(
      name: name,
      valueOf: (_) => throw UnimplementedError(),
      toJson: (value) => value,
      fromJson: (value, {String? name}) => value as T,
      meta: meta,
    );

RevisableStatements<City> _statements<TId>() => RevisableStatements(
  RevisableLayout(
    bean: DataBean<City>(
      name: 'City',
      fields: [
        _field<TId>('id', meta: const [Id()]),
        _field<String>('name'),
      ],
      fromValues: $City.bean.fromValues,
      fromJson: $City.bean.fromJson,
    ),
    schemaName: 'public',
    baseName: 'city',
  ),
);

void main() {
  group('Element locks', () {
    test('lockElements waits in sorted id order', () {
      final sql = _statements<int>().lockElements([3, 1, 2]);
      expect(
        sql.toString(),
        startsWith('SELECT pg_advisory_xact_lock_shared('),
      );
      expect('pg_advisory_xact_lock('.allMatches(sql.toString()), hasLength(3));
      expect(sql.getParameters(), [1, 2, 3]);
    });

    test('tryLockElements keeps the given order', () {
      final sql = _statements<String>().tryLockElements(['b', 'a']);
      expect(
        sql.toString(),
        startsWith('SELECT pg_advisory_xact_lock_shared('),
      );
      expect(
        'pg_try_advisory_xact_lock('.allMatches(sql.toString()),
        hasLength(2),
      );
      expect(sql.getParameters(), ['b', 'a']);
    });
  });

  group('Locked current reads', () {
    test('selectCurrentIds pages like selectCurrent', () {
      final statements = _statements<int>();
      final sql = statements.selectCurrentIds(
        filter: Filter.equals(statements.bean.fields.last, 'x'),
        offset: 5,
        limit: 10,
      );
      expect(
        sql.toString(),
        'SELECT "city"."id" FROM "public"."city" WHERE "city"."name" = '
        '\$1::varchar OFFSET \$2::bigint LIMIT \$3::bigint',
      );
    });

    test('idsFilter matches ids of the element type', () {
      final statements = _statements<int>();
      final sql = statements.selectCurrent(
        filter: statements.idsFilter([1, 2]),
        forUpdate: true,
        skipLocked: true,
      );
      expect(
        sql.toString(),
        contains(
          'WHERE "city"."id" = ANY(\$1::_int8) FOR UPDATE SKIP LOCKED) AS "city"',
        ),
      );
      expect(sql.getParameters(), [
        [1, 2],
      ]);

      final stringStatements = _statements<String>();
      expect(
        stringStatements
            .selectCurrent(
              filter: stringStatements.idsFilter(['a']),
              forUpdate: true,
            )
            .toString(),
        contains(
          'WHERE "city"."id" = ANY(\$1::_varchar) FOR UPDATE) AS "city"',
        ),
      );
    });

    test('selectCurrent without lock is unchanged', () {
      expect(
        _statements<int>().selectCurrent(limit: 1).toString(),
        isNot(contains('FOR UPDATE')),
      );
    });
  });
}
