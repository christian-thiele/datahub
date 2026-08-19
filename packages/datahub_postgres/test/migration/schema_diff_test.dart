import 'dart:convert';

import 'package:datahub/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import '../data/arrays_data.dart';
import '../data/article.dart';
import '../data/city.dart';
import '../data/person.dart';

const _schema = 'public';

SchemaSnapshot _tableSchema(DataBean bean) => SchemaSnapshot.ofRelations([
  DataSchemaBuilder.buildDataTable(bean, schemaName: _schema),
]);

SchemaSnapshot _revisableSchema(DataBean bean) => SchemaSnapshot.ofRelations(
  DataSchemaBuilder.buildRevisableRelations(bean, schemaName: _schema).all,
);

TableSnapshot _table(SchemaSnapshot snapshot, String name) =>
    snapshot['$_schema.$name'] as TableSnapshot;

SchemaSnapshot _replay(SchemaSnapshot from, List<SchemaChange> changes) =>
    changes.fold(from, (snapshot, change) => change.apply(snapshot));

void main() {
  group('Snapshot', () {
    test('json round trip', () {
      for (final snapshot in [
        _tableSchema($Person.bean),
        _tableSchema($ArraysData.bean),
        _revisableSchema($Article.bean),
      ]) {
        final decoded = SchemaSnapshot.fromJson(
          jsonDecode(jsonEncode(snapshot.toJson())) as List<dynamic>,
        );
        expect(decoded, equals(snapshot));
      }
    });

    test('expands auto ids into identity and defaults', () {
      // int @Id(auto: true) becomes an identity column ...
      final person = _table(_tableSchema($Person.bean), 'person');
      expect(person.attribute('id')!.primaryKey, isTrue);
      expect(person.attribute('id')!.identity, isTrue);
      expect(person.attribute('id')!.defaultValue, isNull);

      // ... while a String one gets a uuid default.
      final article = _table(_tableSchema($Article.bean), 'article');
      expect(article.attribute('id')!.identity, isFalse);
      expect(
        article.attribute('id')!.defaultValue,
        equals('gen_random_uuid()'),
      );

      // A non-auto id is a plain primary key.
      final city = _table(_tableSchema($City.bean), 'city');
      expect(city.attribute('id')!.primaryKey, isTrue);
      expect(city.attribute('id')!.identity, isFalse);
      expect(city.attribute('id')!.defaultValue, isNull);
    });

    test('nullable fields are not NOT NULL', () {
      final person = _table(_tableSchema($Person.bean), 'person');
      expect(person.attribute('birthday')!.notNull, isFalse);
      expect(person.attribute('first_name')!.notNull, isTrue);
    });

    test('attribute order is not significant', () {
      final person = _table(_tableSchema($Person.bean), 'person');
      final reordered = person.copyWith(
        attributes: person.attributes.reversed.toList(),
      );

      expect(reordered, equals(person));
      expect(
        SchemaDiff.between(
          SchemaSnapshot.of([person]),
          SchemaSnapshot.of([reordered]),
        ),
        isEmpty,
      );
    });
  });

  group('Diff', () {
    test('is empty for an unchanged model', () {
      for (final snapshot in [
        _tableSchema($Person.bean),
        _tableSchema($City.bean),
        _tableSchema($Article.bean),
        _tableSchema($ArraysData.bean),
        _revisableSchema($Person.bean),
        _revisableSchema($Article.bean),
        _revisableSchema($City.bean),
      ]) {
        expect(
          SchemaDiff.between(snapshot, snapshot),
          isEmpty,
          reason: 'a schema must not differ from itself',
        );
      }
    });

    test('creating a schema from scratch replays back to it', () {
      for (final desired in [
        _tableSchema($Person.bean),
        _revisableSchema($Article.bean),
      ]) {
        final changes = SchemaDiff.between(SchemaSnapshot.empty, desired);
        expect(changes, isNotEmpty);
        expect(_replay(SchemaSnapshot.empty, changes), equals(desired));
      }
    });

    test('adds an attribute', () {
      final before = _tableSchema($Person.bean);
      final table = _table(before, 'person');
      final after = SchemaSnapshot.of([
        table.copyWith(
          attributes: [
            ...table.attributes,
            const AttributeSnapshot(name: 'email', type: 'varchar'),
          ],
        ),
      ]);

      final changes = SchemaDiff.between(before, after);
      expect(changes, hasLength(1));
      expect(changes.single, isA<AddAttribute>());
      expect(changes.single.isDestructive, isFalse);
      expect(changes.single.reviewReason, isNull);
      expect(
        changes.single.toSql().single.toLiteralString(),
        equals('ALTER TABLE "public"."person" ADD COLUMN "email" varchar'),
      );
      expect(_replay(before, changes), equals(after));
    });

    test('flags a NOT NULL attribute without a default for review', () {
      final before = _tableSchema($Person.bean);
      final table = _table(before, 'person');
      final after = SchemaSnapshot.of([
        table.copyWith(
          attributes: [
            ...table.attributes,
            const AttributeSnapshot(
              name: 'email',
              type: 'varchar',
              notNull: true,
            ),
          ],
        ),
      ]);

      expect(
        SchemaDiff.between(before, after).single.reviewReason,
        contains('backfill'),
      );
    });

    test('drops an attribute and marks it destructive', () {
      final before = _tableSchema($Person.bean);
      final table = _table(before, 'person');
      final after = SchemaSnapshot.of([
        table.copyWith(
          attributes: table.attributes
              .where((e) => e.name != 'is_special')
              .toList(),
        ),
      ]);

      final changes = SchemaDiff.between(before, after);
      expect(changes.single, isA<DropAttribute>());
      expect(changes.single.isDestructive, isTrue);
      expect(
        changes.single.toSql().single.toLiteralString(),
        equals('ALTER TABLE "public"."person" DROP COLUMN "is_special"'),
      );
      expect(_replay(before, changes), equals(after));
    });

    test('alters type, nullability and default', () {
      final before = _tableSchema($Person.bean);
      final table = _table(before, 'person');
      final after = SchemaSnapshot.of([
        table.copyWith(
          attributes: [
            for (final a in table.attributes)
              if (a.name == 'last_name')
                a.copyWith(
                  type: 'text',
                  notNull: false,
                  defaultValue: "'unknown'",
                )
              else
                a,
          ],
        ),
      ]);

      final changes = SchemaDiff.between(before, after);
      expect(changes.map((e) => e.runtimeType.toString()), [
        'AlterAttributeType',
        'AlterAttributeNullability',
        'AlterAttributeDefault',
      ]);
      expect(changes.first.isDestructive, isTrue);
      expect(_replay(before, changes), equals(after));
    });

    test('adds and drops table constraints', () {
      final before = _tableSchema($Person.bean);
      final table = _table(before, 'person');
      const constraint = TableConstraintSnapshot(
        name: 'person_last_name_key',
        attributes: ['last_name'],
      );
      final after = SchemaSnapshot.of([
        table.copyWith(constraints: [constraint]),
      ]);

      final added = SchemaDiff.between(before, after);
      expect(added.single, isA<AddTableConstraint>());
      expect(
        added.single.toSql().single.toLiteralString(),
        equals(
          'ALTER TABLE "public"."person" ADD CONSTRAINT '
          '"person_last_name_key" UNIQUE ("last_name")',
        ),
      );
      expect(_replay(before, added), equals(after));

      final dropped = SchemaDiff.between(after, before);
      expect(dropped.single, isA<DropTableConstraint>());
      expect(_replay(after, dropped), equals(before));
    });

    test('recreates a view when the underlying table changes', () {
      final before = _revisableSchema($Person.bean);
      final table = _table(before, 'person_revision');
      const email = AttributeSnapshot(name: 'email', type: 'varchar');
      final view = before['$_schema.person'] as ViewSnapshot;

      final after =
          SchemaSnapshot.of([
            ...before.relations.values.where((e) => e is! TableSnapshot),
            table.copyWith(attributes: [...table.attributes, email]),
          ]).withRelation(
            ViewSnapshot(
              schemaName: view.schemaName,
              name: view.name,
              select: view.select,
              attributes: [
                ...view.attributes,
                const AttributeSnapshot(name: 'email', type: 'varchar'),
              ],
            ),
          );

      final changes = SchemaDiff.between(before, after);

      // The view has to be gone before the table is touched and be put back
      // afterwards, otherwise postgres keeps serving the stale column list.
      expect(changes.first, isA<DropRelation>());
      expect(changes.last, isA<CreateRelation>());
      expect(changes.whereType<AddAttribute>(), hasLength(1));
      expect(_replay(before, changes), equals(after));
    });

    test('refuses to guess a primary key change', () {
      final before = _tableSchema($Person.bean);
      final table = _table(before, 'person');
      final after = SchemaSnapshot.of([
        table.copyWith(
          attributes: [
            for (final a in table.attributes)
              if (a.name == 'id')
                AttributeSnapshot(name: a.name, type: a.type)
              else
                a,
          ],
        ),
      ]);

      expect(
        () => SchemaDiff.between(before, after),
        throwsA(isA<SchemaDiffException>()),
      );
    });
  });
}
