import 'package:datahub/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/data.dart';

sealed class PostgresqlDataRelation {
  String get name;

  DataBean get bean;

  List<PostgresqlAttribute> get attributes;
}

class PostgresqlDataTable extends PostgresqlTable
    implements PostgresqlDataRelation {
  @override
  final DataBean bean;

  PostgresqlDataTable(this.bean)
      : super(
          name: translateName(bean.name),
          attributes: [
            for (final field in bean.fields) PostgresqlDataAttribute(field),
          ],
        );
}

class PostgresqlDataView extends PostgresqlView
    implements PostgresqlDataRelation {
  @override
  final DataBean bean;

  PostgresqlDataView(this.bean, {required SqlSelectTarget target})
      : super(
          name: translateName(bean.name),
          sql: SqlSelect(
            target,
            [
              for (final field in bean.fields)
                SqlAttribute(
                  PostgresqlDataAttribute(field).name,
                  relation: target.name,
                ),
            ],
          ),
          attributes: [
            for (final field in bean.fields) PostgresqlDataAttribute(field),
          ],
        );
}
