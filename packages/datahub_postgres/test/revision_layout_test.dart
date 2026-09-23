import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/src/data/revisable/revisable_layout.dart';
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
}
