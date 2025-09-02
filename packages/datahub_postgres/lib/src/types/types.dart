import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:postgres/src/types/type_registry.dart';
import 'package:postgres/postgres.dart' as pg;

class PostgresqlInt extends PostgresqlDataType<int> {
  const PostgresqlInt()
      : super(TypeOid.bigInteger, 'bigint', pg.Type.bigInteger);
}

class PostgresqlSerial extends PostgresqlDataType<int> {
  const PostgresqlSerial()
      : super(TypeOid.bigInteger, 'serial8', pg.Type.bigSerial);
}

class PostgresqlDouble extends PostgresqlDataType<double> {
  const PostgresqlDouble()
      : super(TypeOid.double, 'double precision', pg.Type.double);
}

class PostgresqlBool extends PostgresqlDataType<bool> {
  const PostgresqlBool() : super(TypeOid.boolean, 'boolean', pg.Type.boolean);
}

class PostgresqlDateTime extends PostgresqlDataType<DateTime> {
  const PostgresqlDateTime()
      : super(TypeOid.timestamp, 'timestamp', pg.Type.timestamp);
}

class PostgresqlString extends PostgresqlDataType<String> {
  const PostgresqlString() : super(TypeOid.varChar, 'varchar', pg.Type.varChar);
}

class PostgresqlText extends PostgresqlDataType<String> {
  const PostgresqlText() : super(TypeOid.text, 'text', pg.Type.text);
}

class PostgresqlJsonMap extends PostgresqlDataType<Map<String, dynamic>> {
  const PostgresqlJsonMap() : super(TypeOid.jsonb, 'jsonb', pg.Type.jsonb);
}

class PostgresqlJsonList extends PostgresqlDataType<List<dynamic>> {
  const PostgresqlJsonList() : super(TypeOid.jsonb, 'jsonb', pg.Type.jsonb);
}

class PostgresqlDynamic extends PostgresqlDataType<dynamic> {
  const PostgresqlDynamic() : super(TypeOid.jsonb, 'jsonb', pg.Type.jsonb);
}
