---
title: Scaffolding
index: 102
---

DataHub applications are structured declaratively using a **component tree** that controls the lifecycle and dependency injection of all services. The entry point for this system is the `runApp` function from `package:datahub/scaffold.dart`.

## Running an Application

```dart
import 'package:datahub/scaffold.dart';

void main(List<String> args) => runApp(
  [
    TelemetryService(),
    MyDatabaseService(),
    ApiService(routes: [MyApiEndpoint()]),
  ],
  arguments: args,
);
```

`runApp` creates an `ApplicationHost`, initialises all components in order, and then waits for a `SIGINT` or `SIGTERM` signal before shutting down gracefully.

## Components

Everything registered in the component tree is a `Component`. There are two kinds:

| Type | Description |
|------|-------------|
| `Service` | A long-running service with an `initialize` / `dispose` lifecycle |
| `Scope` | A logical grouping of components that can share a config prefix |

### Services

To create a service, implement the `Service` interface and return a `ServiceInstance` from `createInstance()`:

```dart
class MyService implements Service {
  // Declare config values and finders here as fields
  final Config<String> greeting;

  const MyService({
    this.greeting = const Config('greeting', defaultValue: 'Hello'),
  });

  @override
  ServiceInstance<MyService> createInstance() => _MyServiceInstance();
}

class _MyServiceInstance extends ServiceInstance<MyService> {
  @override
  Future<void> initialize() async {
    await super.initialize();
    final msg = read(service.greeting);
    log.info('MyService started: $msg');
  }

  @override
  Future<void> dispose() async {
    log.info('MyService stopping.');
    await super.dispose();
  }
}
```

**Inside `initialize()`** a `ServiceInstance` has access to:

- `read(Config<T>)` — reads a configuration value
- `find(Find<T>)` — locates another service in the component tree
- `context` — the current `Context` (zone-based DI scope)
- `service` — the originating `Service` object (holds config declarations)

### Registering Child Services

A service can dynamically register additional child services during its own `initialize()` by calling `registry.register(...)`:

```dart
@override
Future<void> initialize() async {
  await super.initialize();
  registry.register(ChildService());
}
```

Registered children are initialised in order after the parent and disposed in reverse order before it.

---

## Scopes

`Scope` groups components together and can optionally bind them to a config path prefix:

```dart
runApp([
  TelemetryService(),
  Scope(
    name: 'api',
    config: 'api',         // config values under this scope use prefix 'api.'
    components: [
      ApiService(routes: [MyEndpoint()]),
    ],
  ),
]);
```

Scopes are purely organisational — they do not have an `initialize` or `dispose` hook of their own.

---

## Dependency Injection via Context and Zones

DataHub uses Dart **zones** to propagate a `Context` object without passing it through every function call.

### Finding Services

Use the `Find<T>` descriptor to locate a service instance from anywhere inside a running context:

```dart
// In a ServiceInstance:
final db = find(Find<MyDatabaseService>());

// Anywhere inside a running zone (e.g. inside a request handler):
final db = Find<MyDatabaseService>().find();
// or equivalently:
final db = Context.zoneFind(Find<MyDatabaseService>());
```

`Find<T>` searches the component tree starting from the current scope and walking upwards. An optional test predicate can narrow the search:

```dart
final primary = find(Find<DbService>((s) => s.isPrimary));
```

### Context

`Context.ofZone()` retrieves the context active in the current Dart zone. It provides:

| Method | Description |
|--------|-------------|
| `find<T>(Find<T>)` | Locate a service |
| `read<T>(Config<T>)` | Read a config value |
| `session<T>()` | Read the current session (throws if not authenticated) |
| `withSession(session, body)` | Run `body` with an additional session attached |
| `environment` | Current `Environment` (dev / test / stg / prod) |

### Sessions

`Session` is the base interface for authentication principals. Middleware can attach sessions to the context using `context.withSession(...)`. Handlers then retrieve the session with:

```dart
final user = Context.zoneSession<MyUserSession>();
```

If the session is required but absent, `session<T>()` throws an `ApiRequestException.unauthorized()`. Using a nullable type (`session<MyUserSession?>()`) returns `null` instead.

---

## Service Lifecycle

The full lifecycle of a component:

```
runApp()
  └─ ApplicationHost.initialize()
       └─ _initializeComponent() for each Component
            └─ service.createInstance()
                 └─ instance.initialize()   ← your setup code

[application runs …]

SIGINT / SIGTERM received
  └─ ApplicationHost.shutdown()
       └─ _shutdownComponent() (children first, then parent)
            └─ instance.dispose()           ← your teardown code
```

The `ApplicationHost` always adds `TelemetryService` and `KeyService` to an internal scope before your components, so logging and key management are always available.
