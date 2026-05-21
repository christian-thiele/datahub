import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/src/types/postgis/postgis_geography.dart';
import 'package:datahub_postgres/src/types/type_decode_exception.dart';
import 'package:datahub_postgres/src/types/types.dart';
import 'package:postgres/postgres.dart' as pg;

abstract class PostgresqlDataType<T> {
  final String name;
  final pg.Type pgType;

  TypeCheck<T> get type => TypeCheck<T>();

  const PostgresqlDataType(this.name, this.pgType);

  dynamic encode(T? value) => value;

  T? decode(dynamic value) {
    return switch (value) {
      T() => value,
      null => null,
      _ => throw TypeDecodeException.typeMismatch(T, value.runtimeType),
    };
  }

  Sql sqlParam(T? value) => ParameterSql<T>(value, this);

  // TODO general literals not complete
  Sql sqlLiteral(T? value) => switch (value) {
    String() => Sql.text(value),
    Enum() => Sql.text(value.name),
    int() || double() || bool() => RawSql(value.toString()),
    DateTime() => RawSql('"${value.toIso8601String()}"'),
    Map<String, dynamic>() || List<dynamic>() => Sql.join([
      Sql.text(jsonEncode(const JsonDataCodec().encodeDynamic(value))),
      RawSql('::jsonb'),
    ]),
    DataObject() => Sql.text(jsonEncode(value.toJson())) + RawSql('::jsonb'),
    Geometry() => Sql.function('ST_GeogFromWKB', [
      RawSql('\'\\x') +
          RawSql(value.toEWKB().toHexString()) +
          RawSql('\'::bytea'),
    ]),
    null => RawSql('NULL'),
    _ => throw Exception(
      'Cannot provide SQL literal for value of type ${value.runtimeType}.',
    ),
  };

  static PostgresqlDataType findForDataField(DataField field) {
    return switch (field.type) {
      // plain types
      final t when t.isSubtypeOf<String?>() => const PostgresqlString(),
      final t when t.isSubtypeOf<Enum?>() => PostgresqlEnum(
        values: field.constraints.whereType<EnumConstraint>().first.values,
      ),
      final t when t.isSubtypeOf<Enum?>() => const PostgresqlEnum(),
      final t when t.isSubtypeOf<int?>() => const PostgresqlInt(),
      final t when t.isSubtypeOf<double?>() => const PostgresqlDouble(),
      final t when t.isSubtypeOf<bool?>() => const PostgresqlBool(),
      final t when t.isSubtypeOf<DateTime?>() => const PostgresqlDateTime(),
      final t when t.isSubtypeOf<Uint8List?>() => const PostgresqlByteArray(),
      final t when t.isSubtypeOf<Geometry?>() => const PostgisGeography(),
      final t when t.isSubtypeOf<DataObject?>() => PostgresqlObject(
        field.toJson,
        field.fromJson,
      ),
      // list types
      final t when t.isSubtypeOf<List<String>?>() =>
        const PostgresqlStringArray(),
      final t when t.isSubtypeOf<List<Enum>?>() => PostgresqlEnumArray(
        values: field.constraints.whereType<EnumConstraint>().first.values,
      ),
      final t when t.isSubtypeOf<List<int>?>() => const PostgresqlIntArray(),
      final t when t.isSubtypeOf<List<double>?>() =>
        const PostgresqlDoubleArray(),
      final t when t.isSubtypeOf<List<bool>?>() => const PostgresqlBoolArray(),

      // TODO not complete
      // map types
      // TODO not complete
      // json types
      final t when t.isSubtypeOf<List<DataObject>?>() => PostgresqlObject(
        field.toJson,
        field.fromJson,
      ),
      final t when t.isSubtypeOf<Map<DataObject, dynamic>?>() =>
        PostgresqlObject(field.toJson, field.fromJson),
      final t when t.isSubtypeOf<Map<String, dynamic>?>() =>
        const PostgresqlJsonMap(),
      final t when t.isSubtypeOf<List<dynamic>?>() =>
        const PostgresqlJsonList(),
      _ => const PostgresqlDynamic(),
    };
  }

  static PostgresqlDataType findForDynamic(dynamic v) {
    return switch (v) {
      String() => const PostgresqlString(),
      Enum() => const PostgresqlEnum(),
      int() => const PostgresqlInt(),
      double() => const PostgresqlDouble(),
      bool() => const PostgresqlBool(),
      DateTime() => const PostgresqlDateTime(),
      Uint8List() => const PostgresqlByteArray(),
      List<String>() => const PostgresqlStringArray(),
      List<int>() => const PostgresqlIntArray(),
      List<double>() => const PostgresqlDoubleArray(),
      DataObject() => const PostgresqlJsonMap(),
      Geometry() => const PostgisGeography(),
      Map<String, dynamic>() => const PostgresqlJsonMap(),
      List<dynamic>() => const PostgresqlJsonList(),
      null => const PostgresqlNull(),
      _ => const PostgresqlDynamic(),
    };
  }
}
