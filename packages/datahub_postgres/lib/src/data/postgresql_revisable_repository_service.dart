import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/services.dart';

import 'postgresql_revisable_repository.dart';

/// Standalone RevisableDataRepository providing direct access to the postgres data.
///
/// When access control or different behavior is required, use [PostgresqlRevisableRepository]
/// as mixin for a [ServiceInstance] to override methods.
class PostgresqlRevisableRepositoryService<TData extends DataObject<TData>>
    implements Service {
  final Find<Postgresql> postgresql;
  final Config<String> schemaName;
  final Config<String?> relationName;
  final DataBean<TData> bean;

  const PostgresqlRevisableRepositoryService({
    required this.bean,
    this.postgresql = const Find(),
    this.schemaName = const Config('schemaName', defaultValue: 'public'),
    this.relationName = const Config('relationName'),
  });

  @override
  ServiceInstance<PostgresqlRevisableRepositoryService> createInstance() =>
      _PostgresqlRevisableRepositoryServiceInstance<TData>();
}

class _PostgresqlRevisableRepositoryServiceInstance<
  TData extends DataObject<TData>
>
    extends ServiceInstance<PostgresqlRevisableRepositoryService<TData>>
    with
        PostgresqlRevisableRepository<
          PostgresqlRevisableRepositoryService<TData>,
          TData
        >,
        RevisableDataRepository<TData> {
  @override
  Find<Postgresql> get postgresql => service.postgresql;

  @override
  Config<String> get schemaName => service.schemaName;

  @override
  DataBean<TData> get bean => service.bean;
}
