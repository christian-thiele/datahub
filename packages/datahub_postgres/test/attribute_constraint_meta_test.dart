import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/constrained_item.dart';

void main() {
  final table = PostgresqlDataTable<ConstrainedItem>(
    schemaName: 'public',
    bean: $ConstrainedItem.bean,
  );

  PostgresqlAttribute attribute(String name) =>
      table.relation.attributes.firstWhere((e) => e.name == name);

  test('explicit primary key overrides the one derived from Id', () {
    final id = attribute('id');
    expect(id.constraints.whereType<PrimaryKeyConstraint>(), hasLength(1));
    expect(id.hasConstraint<PrimaryKeyConstraint>((e) => !e.auto), isTrue);
    expect(id.hasConstraint<NotNullConstraint>(), isTrue);
  });

  test('unique constraint is taken from meta', () {
    final code = attribute('code');
    expect(code.hasConstraint<UniqueConstraint>(), isTrue);
    expect(code.hasConstraint<NotNullConstraint>(), isTrue);
  });

  test('default constraint is taken from meta', () {
    final createdAt = attribute('created_at');
    expect(
      createdAt.constraints.whereType<DefaultConstraint>().single.value,
      const RawSql('now()'),
    );
    expect(createdAt.hasConstraint<NotNullConstraint>(), isFalse);
  });

  test('explicit not null on nullable field is not duplicated', () {
    final counter = attribute('counter');
    expect(counter.constraints.whereType<NotNullConstraint>(), hasLength(1));
    expect(counter.hasConstraint<DefaultConstraint>(), isTrue);
  });

  test('fields without annotations keep derived behavior', () {
    final note = attribute('note');
    expect(note.constraints, isEmpty);
  });

  test('create table sql contains annotated constraints', () {
    final sql = SqlCreateRelation('public', table.relation).toSql().toString();
    expect(sql, contains('"id" bigint PRIMARY KEY NOT NULL'));
    expect(sql, contains('"code" varchar UNIQUE NOT NULL'));
    expect(sql, contains('"created_at" timestamp DEFAULT now()'));
    expect(sql, contains('"counter" bigint NOT NULL DEFAULT 0'));
    expect(sql, isNot(contains('GENERATED ALWAYS AS IDENTITY')));
  });

  group('DEFAULT on auto id', () {
    const custom = DefaultConstraint(RawSql("make_id(nextval('my_seq'))"));

    DataField<ConstrainedItem, T> field<T>(List<MetaData> meta) =>
        DataField<ConstrainedItem, T>(
          name: 'id',
          valueOf: (_) => throw UnimplementedError(),
          toJson: (value) => value,
          fromJson: (value, {String? name}) => value as T,
          meta: meta,
        );

    String columnSql<T>(List<MetaData> meta) => SqlAttributeDeclaration(
      PostgresqlDataAttribute.fromField(field<T>(meta)),
    ).toSql().toString();

    test('built-in generation without DEFAULT', () {
      expect(
        columnSql<int>(const [Id(auto: true)]),
        '"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY NOT NULL',
      );
      expect(
        columnSql<String>(const [Id(auto: true)]),
        '"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL',
      );
    });

    test('annotated DEFAULT replaces built-in generation', () {
      expect(
        columnSql<int>(const [Id(auto: true), custom]),
        '"id" bigint DEFAULT make_id(nextval(\'my_seq\')) PRIMARY KEY NOT NULL',
      );
      expect(
        columnSql<String>(const [Id(auto: true), custom]),
        '"id" varchar DEFAULT make_id(nextval(\'my_seq\')) PRIMARY KEY NOT NULL',
      );
    });

    test('auto key is still omitted on insert', () {
      final attribute = PostgresqlDataAttribute.fromField(
        field<int>(const [Id(auto: true), custom]),
      );
      expect(
        attribute.hasConstraint<PrimaryKeyConstraint>((e) => e.auto),
        isTrue,
      );
    });
  });
}
