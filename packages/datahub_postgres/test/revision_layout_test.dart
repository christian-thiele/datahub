import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/src/data/revisable/revisable_layout.dart';
import 'package:datahub_postgres/src/data/revisable/revisable_statements.dart';
import 'package:datahub_postgres/src/sql/sql_attribute_constraint.dart';
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

RevisableLayout<City> _layout(List<DataField<City, dynamic>> fields) =>
    RevisableLayout(
      bean: DataBean<City>(
        name: 'City',
        fields: fields,
        fromValues: $City.bean.fromValues,
        fromJson: $City.bean.fromJson,
      ),
      schemaName: 'public',
      baseName: 'city',
    );

void main() {
  test('Layout of a bean', () {
    final layout = _layout($City.bean.fields);
    expect(layout.currentTable.name, 'city');
    expect(layout.historyTable.name, 'city_history');
    expect(layout.scheduleTable.name, 'city_schedule');
  });

  test('Fields must not map to reserved columns', () {
    for (final name in ['sysFrom', 'sysVersion', 'sysTo', 'sysIsDeleted']) {
      expect(
        () => _layout([$City.$id, _field<DateTime>(name)]),
        throwsA(
          isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('reserved for revision metadata'),
          ),
        ),
      );
    }

    expect(_layout([$City.$id, _field<String>('system')]), isNotNull);
  });

  test('Ids must be int or String', () {
    expect(
      _layout([
        _field<int>('id', meta: [const Id()]),
      ]),
      isNotNull,
    );
    expect(
      _layout([
        _field<String>('id', meta: [const Id()]),
      ]),
      isNotNull,
    );

    for (final field in [
      _field<DateTime>('id', meta: [const Id()]),
      _field<int?>('id', meta: [const Id()]),
      _field<double>('id', meta: [const Id(auto: true)]),
    ]) {
      expect(() => _layout([field]), throwsA(isA<ApiError>()));
    }

    expect(() => _layout([_field<int>('id')]), throwsA(isA<Error>()));
  });

  group('Annotated constraints', () {
    const nowDefault = DefaultConstraint(RawSql('now()'));
    const idDefault = DefaultConstraint(RawSql('42'));

    PostgresqlAttribute attribute(PostgresqlTable table, String name) =>
        table.attributes.firstWhere((e) => e.name == name);

    test('DEFAULT is applied in history and current table', () {
      final layout = _layout([
        _field<int>('id', meta: const [Id(auto: true)]),
        _field<DateTime?>('createdAt', meta: const [nowDefault]),
      ]);
      for (final table in [layout.historyTable, layout.currentTable]) {
        final createdAt = attribute(table, 'created_at');
        expect(createdAt.constraints, [nowDefault]);
      }
    });

    test('Keys and NOT NULL annotations are not applied', () {
      final layout = _layout([
        _field<int>('id', meta: const [Id(), PrimaryKeyConstraint()]),
        _field<String?>(
          'code',
          meta: const [UniqueConstraint(), NotNullConstraint()],
        ),
      ]);
      expect(attribute(layout.historyTable, 'id').constraints, [
        const NotNullConstraint(),
      ]);
      expect(attribute(layout.currentTable, 'id').constraints, [
        const PrimaryKeyConstraint(auto: false),
        const NotNullConstraint(),
      ]);
      expect(attribute(layout.historyTable, 'code').constraints, isEmpty);
      expect(attribute(layout.currentTable, 'code').constraints, isEmpty);
    });

    List<String> constraintSql(PostgresqlAttribute attribute) => [
      for (final constraint in attribute.constraints)
        SqlAttributeConstraint(attribute, constraint).toSql().toString(),
    ];

    test('Built-in generation of auto ids', () {
      final intLayout = _layout([
        _field<int>('id', meta: const [Id(auto: true)]),
      ]);
      expect(intLayout.idDefault, isNull);
      expect(intLayout.idSequence, isNotNull);
      expect(
        intLayout.idGenerator.toString(),
        'nextval(\'"public"."city_id_seq"\')',
      );
      expect(constraintSql(attribute(intLayout.historyTable, 'id')), [
        'DEFAULT nextval(\'"public"."city_id_seq"\')',
        'NOT NULL',
      ]);

      final stringLayout = _layout([
        _field<String>('id', meta: const [Id(auto: true)]),
      ]);
      expect(stringLayout.idSequence, isNull);
      expect(stringLayout.idGenerator.toString(), 'gen_random_uuid()::varchar');
      expect(constraintSql(attribute(stringLayout.historyTable, 'id')), [
        'DEFAULT gen_random_uuid()',
        'NOT NULL',
      ]);
    });

    test('DEFAULT on an auto id replaces built-in generation', () {
      const custom = DefaultConstraint(RawSql("make_id(nextval('my_seq'))"));
      for (final layout in [
        _layout([
          _field<int>('id', meta: const [Id(auto: true), custom]),
        ]),
        _layout([
          _field<String>('id', meta: const [Id(auto: true), custom]),
        ]),
      ]) {
        expect(layout.idIsAuto, isTrue);
        expect(layout.idDefault, custom.value);
        expect(layout.idSequence, isNull);
        expect(layout.idGenerator, custom.value);
        expect(constraintSql(attribute(layout.historyTable, 'id')), [
          "DEFAULT make_id(nextval('my_seq'))",
          'NOT NULL',
        ]);
        expect(constraintSql(attribute(layout.currentTable, 'id')), [
          'PRIMARY KEY',
          'NOT NULL',
        ]);
        expect(
          RevisableStatements(layout).allocateId().toString(),
          startsWith("SELECT make_id(nextval('my_seq')), "),
        );
      }
    });

    test('DEFAULT on a non-auto id is applied', () {
      final layout = _layout([
        _field<int>('id', meta: const [Id(), idDefault]),
      ]);
      expect(attribute(layout.historyTable, 'id').constraints, [
        idDefault,
        const NotNullConstraint(),
      ]);
      expect(attribute(layout.currentTable, 'id').constraints, [
        const PrimaryKeyConstraint(auto: false),
        idDefault,
        const NotNullConstraint(),
      ]);
    });
  });
}
