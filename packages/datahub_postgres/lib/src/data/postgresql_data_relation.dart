import 'package:datahub/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/src/data/data_utils.dart';
import 'package:datahub_postgres/src/data/postgresql_data_attribute.dart';

sealed class PostgresqlDataRelation<T extends DataObject<T>> {
  String get name;

  DataBean<T> get bean;

  List<PostgresqlAttribute> get attributes;
}

class PostgresqlDataTable<T extends DataObject<T>> extends PostgresqlTable
    implements PostgresqlDataRelation<T> {
  @override
  final DataBean<T> bean;

  PostgresqlDataTable(this.bean)
      : super(
          name: translateName(bean.name),
          attributes: [
            for (final field in bean.fields) PostgresqlDataAttribute<T>(field),
          ],
        );
}
