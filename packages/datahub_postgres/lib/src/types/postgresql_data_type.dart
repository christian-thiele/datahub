import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/src/types/postgis/postgis_geography.dart';
import 'package:datahub_postgres/src/types/types.dart';
import 'package:postgres/postgres.dart' as pg;

abstract class PostgresqlDataType<T> {
  // TODO really needs oid?
  final int? oid;
  final String name;
  final pg.Type pgType;

  TypeCheck<T> get type => TypeCheck<T>();

  const PostgresqlDataType(this.oid, this.name, this.pgType);

  dynamic encode(T? value) => value;

  T? decode(dynamic value) => value as T?;

  Sql sqlParam(T? value) => Sql.param<T>(value, this);

  Sql sqlLiteral(T? value) => switch (value) {
        String() => Sql.text(value),
        int() || double() || bool() => Sql(value.toString()),
        DateTime() => Sql('"${value.toIso8601String()}"'),
        Map<String, dynamic>() || List<dynamic>() => Sql.combine([
            Sql.text(jsonEncode(const JsonDataCodec().encodeDynamic(value))),
            Sql('::jsonb'),
          ]),
        DataObject() => Sql.combine([
            Sql.text(jsonEncode(value.toJson())),
            Sql('::jsonb'),
          ]),
        Geometry() => Sql.combine([
            Sql('ST_GeogFromWKB(\'\\x'),
            Sql(value.toEWKB().toHexString()),
            Sql('\'::bytea)'),
          ]),
        null => Sql('NULL'),
        _ => throw Exception(
            'Cannot provide SQL literal for value of type ${value.runtimeType}.'),
      };

  static PostgresqlDataType findForType(TypeCheck type) {
    return switch (type) {
      final t when t.isSubtypeOf<String?>() => const PostgresqlString(),
      final t when t.isSubtypeOf<int?>() => const PostgresqlInt(),
      final t when t.isSubtypeOf<double?>() => const PostgresqlDouble(),
      final t when t.isSubtypeOf<bool?>() => const PostgresqlBool(),
      final t when t.isSubtypeOf<DateTime?>() => const PostgresqlDateTime(),
      final t when t.isSubtypeOf<Map<String, dynamic>?>() =>
        const PostgresqlJsonMap(),
      final t when t.isSubtypeOf<List<dynamic>?>() =>
        const PostgresqlJsonList(),
      final t when t.isSubtypeOf<DataObject?>() => const PostgresqlJsonMap(),
      final t when t.isSubtypeOf<Geometry?>() => const PostgisGeography(),
      _ => const PostgresqlDynamic(),
    };
  }

  static PostgresqlDataType findForDynamic(dynamic v) {
    return switch (v) {
      String() => const PostgresqlString(),
      int() => const PostgresqlInt(),
      double() => const PostgresqlDouble(),
      bool() => const PostgresqlBool(),
      DateTime() => const PostgresqlDateTime(),
      Map<String, dynamic>() => const PostgresqlJsonMap(),
      List<dynamic>() => const PostgresqlJsonList(),
      DataObject() => const PostgresqlJsonMap(),
      Geometry() => const PostgisGeography(),
      _ => const PostgresqlDynamic(),
    };
  }
}
