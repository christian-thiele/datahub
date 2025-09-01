import 'package:postgres/postgres.dart' as pg;
import 'package:postgres/src/types/type_registry.dart';


class PostgresqlDataType<T> {
  final int oid;
  final String name;
  final pg.Type pgType;

  const PostgresqlDataType(this.oid, this.name, this.pgType);

  static const bigInt = PostgresqlDataType<int>(TypeOid.bigInteger, 'bigint', pg.Type.bigInteger);
  static const bigSerial = PostgresqlDataType<int>(TypeOid.bigInteger, 'serial8', pg.Type.bigSerial);
  static const doublePrecision = PostgresqlDataType<double>(TypeOid.double, 'double precision', pg.Type.double);
  static const boolean = PostgresqlDataType<bool>(TypeOid.boolean, 'boolean', pg.Type.boolean);
  static const timestamp = PostgresqlDataType<DateTime>(TypeOid.timestamp, 'timestamp', pg.Type.timestamp);
  static const varChar = PostgresqlDataType<String>(TypeOid.varChar, 'varchar', pg.Type.varChar);
  static const text = PostgresqlDataType<String>(TypeOid.text, 'text', pg.Type.text);
  static const jsonb = PostgresqlDataType<Map<String, dynamic>>(TypeOid.jsonb, 'jsonb', pg.Type.jsonb);
}
