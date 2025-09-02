import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/src/revision/revisioned_data_view.dart';
import 'package:datahub_postgres/src/types/types.dart';

class RevisionedSchema implements PostgresqlSchema {
  @override
  final String name;
  @override
  late final List<PostgresqlRelation> relations;

  RevisionedSchema({
    required this.name,
    required List<PostgresqlRelation> relations,
  }) {
    this.relations = [
      // TODO this is only for DataTables, not plain tables. no need for that, just lazy because it needs a RevisionedView (in addition to RevisionedDataView)
      for (final relation in relations.whereType<PostgresqlDataTable>()) ...[
        _buildRevisionTable(relation),
        RevisionedDataView(relation.bean, relation: relation, schemaName: name),
      ],
      for (final relation in relations.whereType<PostgresqlView>()) relation,
    ];
  }

  PostgresqlTable _buildRevisionTable(PostgresqlTable relation) {
    // TODO check for name clashing
    return PostgresqlTable(
      name: '${relation.name}_revision',
      attributes: [
        PostgresqlAttribute(
          name: 'revision_id',
          type: PostgresqlString(),
          constraints: [
            PrimaryKeyConstraint(auto: true),
            NotNullConstraint(),
          ],
        ),
        PostgresqlAttribute(
          name: 'revision_timestamp',
          type: PostgresqlDateTime(),
          constraints: [
            NotNullConstraint(),
          ],
        ),
        PostgresqlAttribute(
          name: 'revision_live',
          type: PostgresqlDateTime(),
        ),
        PostgresqlAttribute(
          name: 'revision_by',
          type: PostgresqlString(),
          constraints: [
            NotNullConstraint(),
          ],
        ),
        PostgresqlAttribute(
          name: 'revision_type',
          type: PostgresqlInt(),
          constraints: [
            NotNullConstraint(),
            DefaultConstraint(0, PostgresqlInt()),
          ],
        ),
        ...relation.attributes.map(_transformAttribute),
      ],
    );
  }

  PostgresqlAttribute _transformAttribute(PostgresqlAttribute attribute) {
    return PostgresqlAttribute(
      name: attribute.name,
      type: attribute.type,
      constraints: attribute.constraints
          .where((e) => e is! PrimaryKeyConstraint && e is! UniqueConstraint)
          .toList(),
    );
  }
}
