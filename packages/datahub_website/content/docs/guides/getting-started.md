---
title: Getting Started
index: 101
---

## Installation

Add `datahub` to your `pubspec.yaml`:

```shell
dependencies:
  datahub: ^0.18.0
```

Or use the Dart CLI:

```shell
dart pub add datahub
```

## Create a Minimal Service

A DataHub application starts with `runApp` and a list of `Component`s:

```dart
import 'package:datahub/scaffold.dart';
import 'package:datahub/api.dart';
import 'package:datahub/telemetry.dart';

void main(List<String> args) =>
    runApp(
      [
        TelemetryService(),
        ApiService(
          routes: [
            ResourceEndpoint(
              matcher: RoutePattern('/hello'),
              get: (request) async => {'message': 'Hello, world!'},
            ),
          ],
        ),
      ],
      arguments: args,
    );
```

Run it:

```shell
dart run bin/main.dart
curl http://localhost:8080/hello
```

Output:

```json
{"message": "Hello, world!"}
```

## Packages Overview

| Package                                          | Purpose                                                      |
|--------------------------------------------------|--------------------------------------------------------------|
| [`datahub`](/docs/api/datahub)                   | Core: scaffold, DI, config, HTTP, API, telemetry, data, auth |
| [`datahub_postgres`](/docs/api/datahub_postgres) | PostgreSQL repositories and SQL generation                   |
| [`datahub_aperture`](/docs/api/datahub_aperture) | Admin UI with CRUD, filtering, revision history              |
| [`boost`](/docs/api/boost)                       | General-purpose Dart utilities                               |

## Next Steps

- [Declarative Structure & Scaffolding](/docs/guides/scaffold) — Learn how the component tree and DI system work
- [Configuration System](/docs/guides/config) — Provide config via YAML files, env vars or CLI flags
- [Data Modelling](/docs/guides/data-modelling) — Declare immutable data objects with validation and serialization
- [Persistence & Repositories](/docs/guides/persistence) — Connect to PostgreSQL using the repository pattern
- [Telemetry](/docs/guides/telemetry) — Add structured logging, Prometheus metrics, and distributed traces
- [Authentication](/docs/guides/auth) — Secure endpoints with JWT / OIDC or Basic Auth
