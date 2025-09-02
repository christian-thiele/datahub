import 'package:datahub/data.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/src/types/types.dart';

class RevisionedDataRepository<DataType extends DataObject<DataType>>
    extends PostgresqlDataRepository<DataType> {
  late final _revisionRelation =
      SqlQualifiedRelation(schema.name, '${dataRelation.name}_revision');

  RevisionedDataRepository({required super.bean});

  @override
  Future<DataType?> get(dynamic id, {String? revisionId}) async {
    if (revisionId != null) {
      return await runTransaction((context) async {
        final data = await context.execute(SqlSelect(
          _revisionRelation,
          [SqlWildcard()],
          where: Sql.combine([
            buildFilterSql(identityFilter(id))!,
            Sql('revision_id = '),
            Sql.param(revisionId, PostgresqlString()),
          ]),
        ));
        if (data.isNotEmpty) {
          return mapResultRow(data.first);
        } else {
          return null;
        }
      });
    } else {
      return await first(filter: identityFilter(id));
    }
  }
}
