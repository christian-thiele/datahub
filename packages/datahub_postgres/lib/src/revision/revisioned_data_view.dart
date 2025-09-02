import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class RevisionedDataView extends PostgresqlView implements PostgresqlDataView {
  @override
  final DataBean bean;

  RevisionedDataView(
    this.bean, {
    required PostgresqlTable relation,
    required String schemaName,
  }) : super(
          name: relation.name,
          sql: SqlSelect(
            SqlNestedSelect(
              name: 'revisions',
              select: SqlSelect(
                SqlQualifiedRelation(
                  schemaName,
                  '${relation.name}_revision',
                ),
                [SqlWildcard()],
                where: Sql('revision_live < now()'),
                order: Sql.combine([
                  _primaryAttribute(relation).toSql(),
                  Sql(', '),
                  SqlAttribute(
                    'revision_timestamp',
                    relation: '${relation.name}_revision',
                  ).toSql(),
                ]),
                distinctOn: _primaryAttribute(relation),
              ),
            ),
            [SqlWildcard()],
            where: Sql('revisions.revision_type > -1'),
          ),
          attributes: relation.attributes,
        );

  static SqlAttribute _primaryAttribute(PostgresqlTable relation) {
    return SqlAttribute(
      relation.attributes
          .firstWhere(
            (e) => e.constraints.any((e) => e is PrimaryKeyConstraint),
            orElse: () => throw ApiError(
                'Relation ${relation.name} does not provide primary key.'),
          )
          .name,
      relation: '${relation.name}_revision',
    );
  }
}
