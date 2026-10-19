import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/services.dart';

import 'postgresql_revisable_repository.dart';

/// Standalone RevisableDataRepository providing direct access to the postgres data.
///
/// When access control or different behavior is required, use [PostgresqlRevisableRepository]
/// as mixin for a [ServiceInstance] to override methods.
class const PostgresqlRevisableRepositoryService<
  TData extends DataObject<TData>
>({
  required final DataBean<TData> bean,
  final Find<Postgresql> postgresql = const Find(),
  final Config<String> schemaName = const Config(
    'schemaName',
    defaultValue: 'public',
  ),
  final Config<String?> relationName = const Config('relationName'),
  final Config<Duration> schedulePollInterval = const Config(
    'schedulePollInterval',
    defaultValue: Duration(seconds: 30),
  ),
  final Config<int> promotionBatchSize = const Config(
    'promotionBatchSize',
    defaultValue: 500,
  ),
}) implements Service {
  @override
  ServiceInstance<PostgresqlRevisableRepositoryService> createInstance() =>
      _PostgresqlRevisableRepositoryServiceInstance<TData>();
}

class _PostgresqlRevisableRepositoryServiceInstance<
  TData extends DataObject<TData>
>()
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
  Config<String?> get relationName => service.relationName;

  @override
  Config<Duration> get schedulePollInterval => service.schedulePollInterval;

  @override
  Config<int> get promotionBatchSize => service.promotionBatchSize;

  @override
  DataBean<TData> get bean => service.bean;
}
