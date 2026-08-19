import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/migration.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/services.dart';

/// Standalone DataRepository providing direct access to the postgres data.
///
/// When access control or different behavior is required, use [PostgresqlDataRepository]
/// as mixin for a [ServiceInstance] to override methods.
class PostgresqlDataRepositoryService<TData extends DataObject<TData>>
    implements PostgresqlSchemaOwner {
  final Find<Postgresql> postgresql;

  @override
  final Config<String> schemaName;

  @override
  final Config<String?> relationName;
  final DataBean<TData> bean;

  const PostgresqlDataRepositoryService({
    required this.bean,
    this.postgresql = const Find(),
    this.schemaName = const Config('schemaName', defaultValue: 'public'),
    this.relationName = const Config('relationName'),
  });

  @override
  List<PostgresqlRelation> buildRelations(
    String schemaName,
    String? relationName,
  ) => [
    DataSchemaBuilder.buildDataTable(
      bean,
      schemaName: schemaName,
      name: relationName,
    ),
  ];

  @override
  ServiceInstance<PostgresqlDataRepositoryService> createInstance() =>
      _PostgresqlDataRepositoryServiceInstance<TData>();
}

class _PostgresqlDataRepositoryServiceInstance<TData extends DataObject<TData>>
    extends ServiceInstance<PostgresqlDataRepositoryService<TData>>
    with
        PostgresqlDataRepository<
          PostgresqlDataRepositoryService<TData>,
          TData
        > {
  @override
  Find<Postgresql> get postgresql => service.postgresql;

  @override
  Config<String> get schemaName => service.schemaName;

  @override
  Config<String?> get relationName => service.relationName;

  @override
  DataBean<TData> get bean => service.bean;
}
