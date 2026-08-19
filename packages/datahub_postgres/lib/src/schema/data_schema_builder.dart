import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

import 'postgresql_attribute.dart';
import 'postgresql_attribute_constraint.dart';
import 'postgresql_relation.dart';
import 'postgresql_table_constraint.dart';
import '../data/postgresql_data_attribute.dart';

/// Derives [PostgresqlRelation]s from a [DataBean].
///
/// This is the single source of truth for the shape of the relations backing
/// a [DataObject]. Both the repositories (which create the relations at
/// startup) and the migration planner (which diffs them against the migration
/// history) build their schema through this class, so that a generated
/// migration always describes exactly what a repository expects to find.
abstract final class DataSchemaBuilder {
  /// The default relation name of [bean], derived from the class name.
  static String relationNameOf(DataBean bean) =>
      toNamingConvention(bean.name, NamingConvention.lowerSnakeCase);

  /// The default attribute name of [field], derived from the field name.
  static String attributeNameOf(DataField field) =>
      toNamingConvention(field.name, NamingConvention.lowerSnakeCase);

  /// Builds the table backing a plain (non-revisable) repository for [bean].
  static PostgresqlTable buildDataTable(
    DataBean bean, {
    required String schemaName,
    String? name,
  }) {
    return PostgresqlTable(
      schemaName: schemaName,
      name: name ?? relationNameOf(bean),
      attributes: [
        for (final field in bean.fields)
          PostgresqlDataAttribute.fromField(field),
      ],
    );
  }

  /// Builds the sequences, revision table and revision view backing a
  /// revisable repository for [bean].
  static RevisableRelations buildRevisableRelations(
    DataBean bean, {
    required String schemaName,
    String? name,
  }) {
    final relationName = name ?? relationNameOf(bean);

    final sequenceFields = bean.fields.where(
      (e) => e.type.isExact<int>() && e.hasMetaOfType<Id>((id) => id.auto),
    );
    final uuidFields = bean.fields.where(
      (e) => e.type.isExact<String>() && e.hasMetaOfType<Id>((id) => id.auto),
    );

    final sequences = [
      for (final sequence in sequenceFields)
        PostgresqlSequence(
          schemaName: schemaName,
          name: '${relationName}_${sequence.name}_seq',
        ),
    ];

    final beanFieldAttributes = {
      for (final field in bean.fields)
        field: PostgresqlDataAttribute(
          field: field,
          name: attributeNameOf(field),
          type: PostgresqlDataType.findForDataField(field),
          constraints: [
            if (sequenceFields.contains(field))
              DefaultConstraint(
                Sql.function('nextval', [
                  Sql.text('$schemaName.${relationName}_${field.name}_seq'),
                ]),
              ),
            if (uuidFields.contains(field))
              DefaultConstraint(RawSql('gen_random_uuid()')),
            if (field is DataField<dynamic, Object>) NotNullConstraint(),
          ],
        ),
    };

    final table = PostgresqlTable(
      schemaName: schemaName,
      name: '${relationName}_revision',
      attributes: [
        sysVersion,
        sysCreator,
        sysCreated,
        sysFrom,
        sysTo,
        sysIsDeleted,
        ...beanFieldAttributes.values,
      ],
      constraints: [
        if (bean.idField case final idField?)
          UniqueTableConstraint(
            attributes: [beanFieldAttributes[idField]!, sysVersion],
          ),
      ],
    );

    final primaryAttribute = beanFieldAttributes[bean.requireIdField]!;

    final view = PostgresqlView(
      schemaName: schemaName,
      name: relationName,
      select: _buildRevisionSelect(table, primaryAttribute),
      attributes: table.attributes,
    );

    return RevisableRelations(
      sequences: sequences,
      table: table,
      view: view,
      primaryAttribute: primaryAttribute,
    );
  }

  static SqlSelect _buildRevisionSelect(
    PostgresqlTable table,
    PostgresqlDataAttribute primaryAttribute,
  ) {
    return SqlSelect(
      Sql.join([
        SqlQualifiedRelation(table.schemaName, table.name),
        RawSql(' INNER JOIN ('),
        SqlSelect(
          SqlQualifiedRelation(table.schemaName, table.name),
          [
            SqlTypedColumnAttribute.of(primaryAttribute, relation: table.name),
            SqlAliasedAttribute(
              'sys_version_max',
              RawSqlAttribute(
                Sql.function('MAX', [
                  SqlTypedColumnAttribute.of(sysVersion, relation: table.name),
                ]),
              ),
            ),
          ],
          where: Sql.join([
            RawSql('now() >= '),
            SqlTypedColumnAttribute.of(sysFrom, relation: table.name),
            RawSql(' AND '),
            Sql.joinWrap([
              SqlTypedColumnAttribute.of(sysTo, relation: table.name),
              RawSql(' IS NULL OR now() <= '),
              SqlTypedColumnAttribute.of(sysTo, relation: table.name),
            ]),
          ]),
          group: SqlTypedColumnAttribute.of(
            primaryAttribute,
            relation: table.name,
          ),
        ),
        RawSql(') "sys_latest" ON '),
        SqlTypedColumnAttribute.of(primaryAttribute, relation: table.name),
        RawSql('= '),
        SqlTypedColumnAttribute.of(primaryAttribute, relation: 'sys_latest'),
        RawSql(' AND '),
        SqlTypedColumnAttribute.of(sysVersion),
        RawSql('= "sys_latest"."sys_version_max"'),
      ]),
      [SqlWildcard(relation: table.name)],
      where: RawSql('NOT ') + SqlTypedColumnAttribute.of(sysIsDeleted),
    );
  }

  static const sysVersion = PostgresqlAttribute(
    name: 'sys_version',
    type: PostgresqlInt(),
    constraints: [NotNullConstraint()],
  );

  static const sysCreator = PostgresqlAttribute(
    name: 'sys_creator',
    type: PostgresqlString(),
  );

  static const sysCreated = PostgresqlAttribute(
    name: 'sys_created',
    type: PostgresqlDateTime(),
    constraints: [NotNullConstraint(), DefaultConstraint(RawSql('now()'))],
  );

  static const sysFrom = PostgresqlAttribute(
    name: 'sys_from',
    type: PostgresqlDateTime(),
    constraints: [NotNullConstraint(), DefaultConstraint(RawSql('now()'))],
  );

  static const sysTo = PostgresqlAttribute(
    name: 'sys_to',
    type: PostgresqlDateTime(),
  );

  static const sysIsDeleted = PostgresqlAttribute(
    name: 'sys_is_deleted',
    type: PostgresqlBool(),
    constraints: [
      NotNullConstraint(),
      DefaultConstraint(ParameterSql(false, PostgresqlBool())),
    ],
  );
}

/// The set of relations backing a revisable repository.
class RevisableRelations {
  final List<PostgresqlSequence> sequences;
  final PostgresqlTable table;
  final PostgresqlView view;
  final PostgresqlDataAttribute primaryAttribute;

  const RevisableRelations({
    required this.sequences,
    required this.table,
    required this.view,
    required this.primaryAttribute,
  });

  /// All relations in the order they have to be created in.
  List<PostgresqlRelation> get all => [...sequences, table, view];
}
