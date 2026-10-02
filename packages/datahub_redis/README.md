<p align="center">
<img src="https://datahubproject.net/logo_shadow.svg" />
</p>

<h2 align="center">DataHub Redis Extension</h2>
<p align="center">
This library is part of the DataHub Project.<br/>
<a href="https://datahubproject.net">https://datahubproject.net</a>
</p>

![Pub Version](https://img.shields.io/pub/v/datahub_redis?color=2CB7F6&label=pub.dev&logo=dart&style=flat-square)
![Pub Likes](https://img.shields.io/pub/likes/datahub_redis?color=2CB7F6&label=pub.dev%20likes&style=flat-square)

> DataHub is a Cloud Development Ecosystem aiming to bring the power of Dart into the Cloud.

*DataHub is still under development and is not to be considered production ready. Comprehensive documentation is yet to
be released.*

---

### Features

This library contains Services and Components for using [Redis](https://redis.io) (and compatible servers like
Valkey) within the DataHub Framework:

- `RedisService` providing the `Redis` interface with a pooled connection
- typed methods for common commands and `execute` for everything else
- pipelining, transactions (`MULTI` / `EXEC`) and optimistic locking (`WATCH`)
- Pub/Sub on a dedicated connection that is health checked and re-established automatically
- Lua scripts via `EVALSHA` with transparent fallback to `EVAL`
- a distributed `LockProvider<String>` with automatic lease renewal

The RESP2 protocol is implemented by this library, it has no dependency on a Redis client package.

### Usage

Add `datahub_redis` to the `dependencies` section of your projects
`pubspec.yaml` file, or simply run:

```shell
$ dart pub add datahub_redis
```

Register the service, typically inside a scope that holds its configuration:

```dart
Scope(
  config: 'redis',
  components: [RedisService()],
)
```

```yaml
redis:
  host: redis.internal
  password: $env.REDIS_PASSWORD
```

Then use it from any other service or endpoint:

```dart
final redis = Find<Redis>().find();

await redis.set('session:42', token, ttl: const Duration(hours: 1));
final session = await redis.get('session:42');

// pipelined on a single connection, one round trip
final values = await redis.useConnection(
  (connection) => Future.wait([for (final key in keys) connection.get(key)]),
);

// atomic, results are available after the transaction was executed
late Future<int> visits;
await redis.transaction((tx) {
  visits = tx.incr('visits');
  tx.expire('visits', const Duration(days: 1));
});

// commands without typed method
final reply = await redis.execute(['OBJECT', 'ENCODING', 'visits']);
print(reply.asString);

// Pub/Sub
redis.subscribe('events').listen((message) => print(message.payload));
await redis.publish('events', 'hello');
```

Distributed locks are available through the `LockProvider` interface of the
DataHub framework:

```dart
final locks = Find<LockProvider<String>>().find();
await locks.runLocked('nightly-report', () async {
  // only one instance runs this at a time
}, timeout: const Duration(seconds: 10));
```

### Configuration

| Path                      | Default         | Description                                                           |
|---------------------------|-----------------|-----------------------------------------------------------------------|
| `host`                    | `localhost`     | Redis host                                                            |
| `port`                    | `6379`          | Redis port                                                            |
| `username`                | –               | ACL user, only used together with `password`                          |
| `password`                | –               | Password, no authentication if not set                                |
| `database`                | `0`             | Database index                                                        |
| `useTls`                  | `false`         | Connect using TLS                                                     |
| `serviceName`             | `DataHub`       | Client name reported to the server (`CLIENT SETNAME`)                 |
| `timeout`                 | `10000` (ms)    | Timeout for establishing a connection including authentication        |
| `commandTimeout`          | `10000` (ms)    | Default timeout per command                                           |
| `targetPoolSize`          | `4`             | Number of pooled connections                                          |
| `maxConnectionLifetime`   | `3600000` (ms)  | Idle connections older than this are replaced                         |
| `poolTimeout`             | `5000` (ms)     | Maximum time to wait for a pooled connection                          |
| `poolQueueLimit`          | `1000`          | Maximum number of requests waiting for a pooled connection            |
| `poolMaintenanceInterval` | `30000` (ms)    | Interval for evicting expired and refilling connections               |
| `healthCheckInterval`     | `30000` (ms)    | Idle time after which pooled connections are pinged before use        |
| `lockPrefix`              | `datahub:lock:` | Key prefix for locks                                                  |
| `lockLeaseDuration`       | `30000` (ms)    | Time after which a lock of a crashed holder expires                   |
| `lockRetryInterval`       | `500` (ms)      | Polling interval of waiting lock acquirers (in addition to Pub/Sub)   |
| `enableMetrics`           | `true`          | Publish pool metrics                                                  |
| `metricPrefix`            | `redis`         | Prefix of the pool metrics                                            |

### Behaviour worth knowing

- **Timeouts close connections.** When a command times out, its reply could still arrive later and be taken for
  the reply of the next command, so the connection is closed and replaced. Blocking commands (`BLPOP`, `XREAD BLOCK`,
  ...) need a longer timeout: `redis.execute(['BLPOP', 'queue', 5], timeout: const Duration(seconds: 10))`.
- **Connection state is reset.** A different database selected with `SELECT`, watched keys and an unfinished `MULTI`
  are reset before a connection returns to the pool. Commands that change the protocol of a connection
  (`SUBSCRIBE`, `MONITOR`, `HELLO`, `RESET`, `QUIT`, `CLIENT REPLY`) are rejected, use `subscribe` instead.
- **Transactions are synchronous.** Commands are queued while the transaction callback runs and sent in a single round
  trip. Their futures complete after `EXEC`, so awaiting them inside the callback does not work. Read values before
  and use `WATCH` (see `RedisConnection.transaction`).
- **Text and bytes.** Values are written as UTF-8 text, numbers or raw bytes (`Uint8List`). Methods returning text
  decode values as UTF-8, use `getBytes` or `execute(...).asBytes` for binary data.
- **Locks** are as safe as a single Redis server is: they are exclusive across all instances using the same server
  and survive network hiccups shorter than the lease, but they can be granted twice after a failover to a replica
  that did not receive the lock key yet. Waiters are not served in FIFO order.
- Redis Cluster and Sentinel are not supported.


[1]: https://github.com/christian-thiele/datahub
