import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/src/types/types.dart';
import 'package:postgres/postgres.dart' as pg;

abstract class PostgresqlDataType<T> {
  final int? oid;
  final String name;
  final pg.Type pgType;
  TypeCheck<T> get type => TypeCheck<T>();

  const PostgresqlDataType(this.oid, this.name, this.pgType);

  Sql sqlParam(T? value) => Sql.param<T>(value, this);

  static PostgresqlDataType findForType(TypeCheck type) {
    return switch (type) {
      final t when t.isSubtypeOf<String>() => const PostgresqlString(),
      final t when t.isSubtypeOf<int>() => const PostgresqlInt(),
      final t when t.isSubtypeOf<double>() => const PostgresqlDouble(),
      final t when t.isSubtypeOf<bool>() => const PostgresqlBool(),
      final t when t.isSubtypeOf<DateTime>() => const PostgresqlDateTime(),
      final t when t.isSubtypeOf<Map<String, dynamic>>() =>
        const PostgresqlJsonMap(),
      final t when t.isSubtypeOf<List<dynamic>>() => const PostgresqlJsonList(),
      final t when t.isSubtypeOf<DataObject>() => const PostgresqlObject(),
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
      DataObject() => const PostgresqlObject(),
      _ => const PostgresqlDynamic(),
    };
  }
}
