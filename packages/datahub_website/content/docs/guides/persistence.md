---
title: Persistence & Repositories
index: 105
---

DataHub provides a generic repository abstraction that decouples your application code from the underlying storage engine. The core interface is `DataRepository<T>`, which any storage backend can implement.

## DataRepository

`DataRepository<T>` is the standard CRUD interface for a `DataObject`:

```dart
abstract class DataRepository<T extends DataObject> {
  DataBean<T> get bean;

  Future<T>         create(T element);
  Future<T?>        readById(dynamic id);
  Future<List<T>>   readAll({Filter filter, Sort sort, int? offset, int? limit});
  Future<int>       count({Filter filter});
  Future<bool>      updateById(T element);
  Future<int>       updateAll({required Filter filter, required Map<DataField, dynamic> values});
  Future<bool>      deleteById(dynamic id);
  Future<int>       deleteAll({required Filter filter});
  Future<R>         atomic<R>(Future<R> Function() delegate);
}
```

### Filtering and Sorting

Pass `Filter` and `Sort` values built from your data bean's fields:

```dart
final users = await userRepo.readAll(
  filter: User.activeField.equals(true)
      .and(User.roleField.equals('admin')),
  sort: User.createdField.desc(),
  offset: 0,
  limit: 20,
);
```

See [Data Modelling](/docs/guides/data-modelling) for the full filter and sort DSL.

### Atomic Transactions

Wrap multiple operations in a single transaction:

```dart
await userRepo.atomic(() async {
  final user = await userRepo.readById(userId);
  if (user == null) throw NotFoundException();

  await userRepo.updateById(user.copyWith(balance: user.balance - 100));
  await ledgerRepo.create(LedgerEntry(userId: userId, amount: -100));
});
```

### Convenience Extension

The `DataRepositoryExtension` adds a `first()` helper:

```dart
final user = await userRepo.first(
  filter: User.emailField.equals('alice@example.com'),
);
```

---

## RevisableDataRepository

`RevisableDataRepository<T>` extends `DataRepository<T>` to add **time-travel** semantics. Every write creates a new revision row instead of overwriting the previous one. This enables full audit trails and point-in-time reads.

The mixin overrides the standard CRUD methods to delegate to `createRevision()`:

| Type | Revision type code | Meaning |
|------|--------------------|---------|
| Create | `1` | Element did not exist before |
| Update | `0` | Element already exists |
| Delete | `-1` | Soft-delete; element marked as removed |

Additional methods:

```dart
// Read the latest revision (by default)
Future<RevisionData<T>?> revisableReadById(dynamic id, {int? version});

// Read all current elements (latest revisions, deletions filtered out)
Future<List<RevisionData<T>>> revisableReadAll({Filter, Sort, offset, limit});

// Full revision history for a single element
Future<List<RevisionData<T>>> readRevisionsById(dynamic id, {offset, limit});

// Low-level: write a revision directly
Future<RevisionData<T>> createRevision(T data, {DateTime? from, required int type});
```

`RevisionData<T>` wraps the data with revision metadata:

| Field | Type | Description |
|-------|------|-------------|
| `data` | `T` | The element value at this revision |
| `version` | `int` | Monotonically increasing revision number |
| `created` | `DateTime` | When this revision was written |
| `from` | `DateTime?` | Validity start for time-based queries |
| `isDeleted` | `bool` | Whether this revision represents a deletion |
| `creator` | `String?` | Identity of the user who made the change |

### Reading Specific Versions

```dart
// Read the element as it was at revision 3
final oldVersion = await userRepo.revisableReadById(userId, version: 3);

// Full history
final history = await userRepo.readRevisionsById(userId);
for (final rev in history) {
  print('v${rev.version} — ${rev.created}: ${rev.data.name}');
}
```

---

## PostgreSQL Repositories

The `datahub_postgres` package provides concrete implementations of these interfaces backed by PostgreSQL.

### PostgresqlDataRepositoryService

The simplest approach is to use `PostgresqlDataRepositoryService<T>` as a drop-in service — no custom code needed:

```dart
runApp([
  TelemetryService(),
  PostgresqlService(),
  Scope(
    config: 'users',
    components: [
      PostgresqlDataRepositoryService(bean: $User.bean),
    ],
  ),
]);
```

Configuration:

```yaml
users:
  schemaName: public      # PostgreSQL schema (default: public)
  relationName: users     # Table name (default: derived from bean.name)
```

The service auto-creates the table on startup using the field types from the `DataBean`.

### Custom Repository Service

For custom behaviour (access control, computed fields, etc.) mix `PostgresqlDataRepository` into your own `ServiceInstance`:

```dart
class UserRepositoryService implements Service {
  @override
  ServiceInstance<UserRepositoryService> createInstance() => _UserRepoInstance();
}

class _UserRepoInstance extends ServiceInstance<UserRepositoryService>
    with PostgresqlDataRepository<UserRepositoryService, User>
    implements DataRepository<User> {

  @override
  Find<Postgresql> get postgresql => const Find();

  @override
  Config<String> get schemaName => const Config('schemaName', defaultValue: 'public');

  @override
  Config<String?> get relationName => const Config('relationName');

  @override
  DataBean<User> get bean => $User.bean;

  // Override methods for custom behaviour:
  @override
  Future<User?> readById(dynamic id) async {
    final user = await super.readById(id);
    if (user != null && !hasPermission(user)) return null;
    return user;
  }
}
```

### PostgresqlRevisableRepositoryService

For revisable data use `PostgresqlRevisableRepositoryService<T>`:

```dart
PostgresqlRevisableRepositoryService(bean: $Document.bean)
```

This creates a separate revisions table in addition to the main table.

### PostgresqlService Configuration

`PostgresqlService` reads its connection settings from config:

```yaml
# Default config paths (relative to the service's config scope)
host: localhost
port: 5432
database: myapp
username: app_user
password: secret
useSsl: true
logStatements: false      # Log SQL to console
targetPoolSize: 3         # Connection pool size
maxConnectionLifetime: 3600s
poolTimeout: 5s
queryTimeout: 30s
timeZone: UTC
enableMetrics: true
metricPrefix: postgresql
```

---

## Reactive Repositories

The `datahub_amqp` package provides stream-based reactive repositories that publish change events over AMQP. These let consumers react to data changes in real time without polling.

See the `datahub_amqp` package for details.
