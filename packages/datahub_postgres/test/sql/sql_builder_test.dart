import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';
import 'package:test/test.dart';

const _id = PostgresqlAttribute(name: 'id', type: PostgresqlInt());
const _name = PostgresqlAttribute(name: 'name', type: PostgresqlString());
const _version = PostgresqlAttribute(
  name: 'sys_version',
  type: PostgresqlInt(),
);

const _table = SqlQualifiedRelation('public', 'item');

void main() {
  test('Insert with upsert', () {
    final sql = SqlInsert(
      _table,
      {SqlTypedAttribute.of(_id): 1, SqlTypedAttribute.of(_name): 'a'},
      onConflict: SqlOnConflict.doUpdate(
        [SqlColumnAttribute('id')],
        {SqlColumnAttribute('name'): SqlOnConflict.excluded(_name)},
        where: RawSql('"item"."id" > 0'),
      ),
      returning: [SqlWildcard()],
    );

    expect(
      sql.toString(),
      'INSERT INTO "public"."item" ("id", "name") VALUES (\$1::bigint, '
      '\$2::varchar) ON CONFLICT ("id") DO UPDATE SET "name" = '
      '"excluded"."name" WHERE "item"."id" > 0 RETURNING *',
    );
    expect(sql.getParameters(), [1, 'a']);
  });

  test('Insert do nothing', () {
    expect(
      SqlInsert(_table, {
        SqlTypedAttribute.of(_id): 1,
      }, onConflict: const SqlOnConflict.doNothing([])).toString(),
      'INSERT INTO "public"."item" ("id") VALUES (\$1::bigint) '
      'ON CONFLICT DO NOTHING',
    );
  });

  test('Insert from select', () {
    expect(
      SqlInsertSelect(
        _table,
        [SqlColumnAttribute('id'), SqlColumnAttribute('name')],
        SqlSelect(Sql.name('src'), [
          SqlColumnAttribute('id', relation: 'src'),
          RawSqlAttribute(ParameterSql('b', const PostgresqlString())),
        ]),
        returning: [SqlColumnAttribute('id')],
      ).toString(),
      'INSERT INTO "public"."item" ("id", "name") SELECT "src"."id", '
      '\$1::varchar FROM "src" RETURNING "id"',
    );
  });

  test('Delete using, returning', () {
    expect(
      SqlDelete(
        _table,
        RawSql('"item"."id" = "src"."id"'),
        using: Sql.name('src'),
        returning: [SqlColumnAttribute('id')],
      ).toString(),
      'DELETE FROM "public"."item" USING "src" WHERE "item"."id" = "src"."id" '
      'RETURNING "id"',
    );
  });

  test('Update from', () {
    expect(
      SqlUpdate(_table, RawSql('"item"."id" = "src"."id"'), {
        SqlTypedAttribute.of(_name, relation: 'item'): SqlColumnAttribute(
          'name',
          relation: 'src',
        ),
        SqlTypedAttribute.of(_version): 2,
      }, from: Sql.name('src')).toString(),
      'UPDATE "public"."item" SET "name" = "src"."name", "sys_version" = '
      '\$1::bigint FROM "src" WHERE "item"."id" = "src"."id"',
    );
  });

  test('With', () {
    final sql = SqlWith([
      SqlCte(
        'ins',
        SqlInsert(
          _table,
          {SqlTypedAttribute.of(_id): 1},
          returning: [SqlWildcard()],
        ),
      ),
      SqlCte('del', SqlDelete(_table, RawSql('"id" = 2'))),
    ], SqlSelect(Sql.name('ins'), [SqlWildcard()]));

    expect(
      sql.toString(),
      'WITH "ins" AS (INSERT INTO "public"."item" ("id") VALUES (\$1::bigint) '
      'RETURNING *), "del" AS (DELETE FROM "public"."item" WHERE "id" = 2) '
      'SELECT * FROM "ins"',
    );
  });

  test('Nested select is wrapped', () {
    expect(
      SqlNestedSelect(
        name: 'sub',
        select: SqlSelect(_table, [SqlWildcard()]),
      ).toString(),
      '(SELECT * FROM "public"."item") "sub"',
    );
  });

  test('Primary key table constraint', () {
    expect(
      SqlCreateRelation(
        'public',
        const PostgresqlTable(
          schemaName: 'public',
          name: 'item',
          attributes: [_id, _version],
          constraints: [
            PrimaryKeyTableConstraint(attributes: [_id, _version]),
          ],
        ),
      ).toLiteralString(),
      'CREATE TABLE "public"."item" ("id" bigint, "sys_version" bigint, '
      'PRIMARY KEY ("id","sys_version"))',
    );
  });
}
