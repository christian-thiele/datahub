import 'package:postgres/postgres.dart';
import 'package:postgres/postgres_v3_experimental.dart';

class PostgresValue<T extends Object> {
  final String literal;
  final T value;
  final PgDataType<T> type;

  PostgresValue(this.literal, this.value, this.type);
}