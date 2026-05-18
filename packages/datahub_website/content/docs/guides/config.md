---
title: Configuration System
index: 103
---

DataHub has a built-in hierarchical configuration system that supports YAML files, JSON files, command-line arguments and hardcoded values. Configuration values are declared as typed constants on `Service` objects and resolved at runtime through the `Context`.

## Declaring Configuration Values

Use the `Config<T>` type to declare configuration values on your service:

```dart
class MyService implements Service {
  final Config<String> host;
  final Config<int> port;
  final Config<bool> enableFeature;

  const MyService({
    this.host = const Config('host', defaultValue: 'localhost'),
    this.port = const Config('port', defaultValue: 8080),
    this.enableFeature = const Config('features.newDashboard', defaultValue: false),
  });

  @override
  ServiceInstance<MyService> createInstance() => _MyServiceInstance();
}
```

Inside a `ServiceInstance`, read values using `read(config)`:

```dart
class _MyServiceInstance extends ServiceInstance<MyService> {
  @override
  Future<void> initialize() async {
    await super.initialize();
    final host = read(service.host);
    final port = read(service.port);
    log.info('Connecting to $host:$port');
  }
}
```

## Config Types

| Type | Constructor | Description |
|------|-------------|-------------|
| `PathConfig<T>` | `Config('some.path')` | Reads a value from a dot-separated key path |
| `ValueConfig<T>` | `Config.value(42)` | Returns a hardcoded value, useful for tests |

### Path-based Config

Config paths use dots as separators and are resolved against the configuration map:

```dart
// Reads configuration at key: "database" → "host"
const Config<String>('database.host', defaultValue: 'localhost')
```

If a `defaultValue` is given the config returns it when the key is missing. Without a default, a missing key throws a `ConfigPathException`.

### Enum Config

Enums are read by their string name. Supply `values:` to enable correct decoding:

```dart
const Config<Environment>(
  'environment',
  values: Environment.values,
  defaultValue: Environment.dev,
)
```

For enums implementing `DataEnum`, the `jsonValue` property is used instead of `name`.

### Hardcoded Values

Use `Config.value(...)` when you want to pin a setting regardless of what the configuration system contains. This is useful in tests:

```dart
MyService(
  host: const Config.value('test-host'),
  port: const Config.value(9999),
)
```

## Providing Configuration

### YAML / JSON Files

Pass config files via `--file` / `-f` on the command line:

```bash
dart run my_app.dart -f config.yaml -f secrets.json
```

`config.yaml`:
```yaml
database:
  host: db.prod.example.com
  port: 5432
  password: secret

telemetry:
  logLevel: info
```

Files are deep-merged in order — later files override earlier ones at the same path.

Supported formats: `.yaml`, `.yml`, `.json`.

### Command-Line Directives

Individual values can be overridden with `--config` / `-c`:

```bash
dart run my_app.dart -f config.yaml -c database.host=localhost
```

Syntax: `path.to.key=value`. Directives and files are applied in the order they appear on the command line, so a later `-c` can override an earlier `-f`.

### Hardcoded Initial Config

Pass a map to `runApp` for values that are always present (e.g. in tests):

```dart
await runApp(
  [MyService()],
  config: {
    'database': {'host': 'localhost', 'port': 5432},
  },
);
```

## Config Scopes

A `Scope` can bind its components to a config sub-path using the `config:` parameter. All `Config` paths inside that scope are resolved relative to it:

```dart
runApp([
  Scope(
    name: 'api',
    config: 'api',    // scopes config to the 'api' sub-tree
    components: [
      ApiService(
        // reads 'api.port', not 'port'
        port: const Config('port', defaultValue: 8080),
      ),
    ],
  ),
]);
```

```yaml
api:
  port: 3000
```

## Reading Config Outside a ServiceInstance

Anywhere inside a running Dart zone (e.g. in request handlers) you can read config via `Context`:

```dart
final host = Context.zoneRead(const Config<String>('database.host'));
// or equivalently:
final host = const Config<String>('database.host').read();
```

## Environment

The special key `environment` controls the `Environment` enum and is readable everywhere:

```dart
if (Context.ofZone().environment == Environment.dev) {
  // development-only behaviour
}
```

| Value | Description |
|-------|-------------|
| `dev` | Local development (default) |
| `test` | Automated tests |
| `stg` | Staging |
| `prod` | Production |
