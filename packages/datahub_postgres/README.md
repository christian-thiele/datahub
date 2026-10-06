<p align="center">
<img src="https://datahubproject.net/logo_shadow.svg" />
</p>

<h2 align="center">DataHub PostgreSQL Extension</h2>
<p align="center">
This library is part of the DataHub Project.<br/>
<a href="https://datahubproject.net">https://datahubproject.net</a>
</p>

![Pub Version](https://img.shields.io/pub/v/datahub_postgres?color=2CB7F6&label=pub.dev&logo=dart&style=flat-square)
![Pub Likes](https://img.shields.io/pub/likes/datahub_postgres?color=2CB7F6&label=pub.dev%20likes&style=flat-square)

> DataHub is a Cloud Development Ecosystem aiming to bring the power of Dart into the Cloud.

*DataHub is still under development and is not to be considered production ready. Comprehensive documentation is yet to
be released.*

---

### Features

This library contains Services and Components for using PostgreSQL within the DataHub Framework.
It works as an adapter between DataHub and the [postgres](https://pub.dev/packages/postgres) dart library.

### Usage

Add `datahub_postgres` to the `dependencies` section of your projects
`pubspec.yaml` file, or simply run:

```shell
$ dart pub add datahub_postgres
```

### Telemetry

`PostgresqlService` publishes metrics (`enableMetrics`, default `true`) named `<metricPrefix>_<name>` (default prefix
`postgresql`):

| Metric                                                   | Type      | Description                                            |
|----------------------------------------------------------|-----------|--------------------------------------------------------|
| `queries_total{status}`                                  | counter   | Queries by result (`ok`, `error`)                      |
| `query_duration_seconds`                                 | histogram | Time from sending a query until its result was received |
| `pool_size_target` / `_total` / `_available` / `_in_use` | gauge     | State of the connection pool                           |
| `pool_wait_seconds`                                      | histogram | Wait for a pooled connection                           |

With `enableTracing` (default `true`), queries are traced as spans of kind `client` named after the operation (e.g.
`SELECT`), with the attributes `db.system.name`, `db.namespace`, `db.operation.name`, `server.address` and
`server.port`, and `error.type` and `db.response.status_code` (the SQLSTATE) on failure. `db.query.text` is added for
parameterized queries, and for queries with inlined values only if `logStatements` is enabled. Transactions are
spans named `postgresql transaction`.


[1]: https://github.com/christian-thiele/datahub