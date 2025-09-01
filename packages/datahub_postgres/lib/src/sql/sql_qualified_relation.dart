import 'sql.dart';

class SqlQualifiedRelation {
  final String? schema;
  final String relation;

  SqlQualifiedRelation(this.schema, this.relation);

  @override
  String toString() {
    final buffer = StringBuffer();
    if (schema case final schema?) {
      buffer.write(Sql.escapeName(schema));
      buffer.write('.');
    }
    buffer.write(Sql.escapeName(relation));
    return buffer.toString();
  }

  Sql toSql() => Sql(toString());
}
