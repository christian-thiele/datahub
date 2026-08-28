<p align="center">
<img src="https://datahubproject.net/logo_shadow.svg" />
</p>

<h2 align="center">DataHub Lints</h2>
<p align="center">
This library is part of the DataHub Project.<br/>
<a href="https://datahubproject.net">https://datahubproject.net</a>
</p>

![Pub Version](https://img.shields.io/pub/v/datahub_lints?color=2CB7F6&label=pub.dev&logo=dart&style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/christian-thiele/datahub?style=flat-square)
![Pub Likes](https://img.shields.io/pub/likes/datahub_lints?color=2CB7F6&label=pub.dev%20likes&style=flat-square)

> DataHub is a Cloud Development Ecosystem aiming to bring the power of Dart into the Cloud.

*DataHub is still under development and is not to be considered production ready. Comprehensive documentation is yet to
be released.*

---

Analysis rules, quick fixes and assists for the [DataHub][] framework.

DataHub has conventions the Dart analyzer cannot see on its own: resolving a
dependency through the wrong context, declaring an enum config without its
values, or writing a `@Data()` class the generator cannot read. Each of those
fails at runtime or during `build_runner` rather than during analysis. This
package reports them as you type, and offers a fix for most of them.

### Setup

Add a top-level `plugins` section to your `analysis_options.yaml`:

```yaml
plugins:
  datahub_lints: ^0.18.0-dev.1
```

That is all — the plugin is not a dependency of your package, and there is no
separate command to run. The rules show up in your IDE and in `dart analyze`.

> **Requires Dart 3.10 or newer.** On older SDKs the `plugins` section is
> ignored, so nothing breaks — you just get no rules.
>
> **Restart the Dart Analysis Server** after changing the `plugins` section.
>
> In a [pub workspace][], plugins are configured **only** in the analysis
> options file at the workspace root. A package with its own
> `analysis_options.yaml` does not inherit the workspace root's plugins, so
> either remove the nested file or make the workspace root the only one.

### Rules

| | Severity | Default |
|---|---|---|
| 🛑 | error | on — fails `dart analyze` |
| ⚠️ | warning | on — fails `dart analyze` |
| 💡 | lint | off, switch it on under `diagnostics` |

#### Services and dependency injection

| Rule | Reports | Fix |
|------|---------|-----|
| `prefer_instance_find` ⚠️ | `finder.find()` inside a `ServiceInstance`, which resolves through the caller's zone instead of the service's own context | `find(finder)` |
| `prefer_instance_read` ⚠️ | `config.read()` inside a `ServiceInstance` | `read(config)` |
| `avoid_zone_context_in_service` ⚠️ | `Context.ofZone()`, `Context.zoneFind()` and friends inside a `ServiceInstance` | `find(x)` / `read(x)` |
| `await_lifecycle_super` ⚠️ | `super.initialize()` / `super.dispose()` left unawaited; both return `FutureOr<void>` | add `await` |
| `avoid_injection_in_initializer` ⚠️ | `find()`, `read()` or `context` in a `ServiceInstance` constructor, where the context is not assigned yet | — |
| `const_service_constructor` 💡 | a `Service` implementation without a const constructor | add `const` |

#### Configuration

| Rule | Reports | Fix |
|------|---------|-----|
| `enum_config_requires_values` 🛑 | `Config<SomeEnum>('path')` without `values:` | add `values: SomeEnum.values` |

#### Data classes

| Rule | Reports | Fix |
|------|---------|-----|
| `data_class_requires_part` ⚠️ | a `@Data()` class in a library without its `part '….g.dart';` | add the directive |
| `data_class_extends_generated` ⚠️ | a `@Data()` class that does not extend `$Name` | add the superclass |
| `data_class_const_constructor` ⚠️ | a `@Data()` class without an unnamed const constructor, or one taking positional parameters | add `const` / write the constructor |

#### PostgreSQL

| Rule | Reports | Fix |
|------|---------|-----|
| `postgres_repository_requires_super_initialize` ⚠️ | an `initialize()` override that never calls `super.initialize()` while mixing in `PostgresqlDataRepository` or `DatabaseConnectionManager` | add the call |

#### Aperture

| Rule | Reports | Fix |
|------|---------|-----|
| `aperture_relation_requires_relation_id` ⚠️ | `@ApertureRelation<T>()` where `T` has no field annotated `@RelationId<Owner>()` | — |

### Assists

Available from the IDE at a class declaration (Alt+Enter in IntelliJ, Ctrl+. in
VS Code). Generated names and types are editable placeholders you can tab
through.

| Assist | Offered on | Generates |
|--------|-----------|-----------|
| Generate ServiceInstance | a `Service` without `createInstance()` | the `createInstance()` override and the matching `ServiceInstance` class |
| Convert to DataHub data class | a plain class | `@Data()`, the `$Name` superclass, the part directive and a const constructor over the fields |
| Add Find injection field | a `Service` | a `final Find<T> name;` field and its constructor parameter |

### Configuration

Switch any rule on or off under `diagnostics`, whatever its default severity:

```yaml
plugins:
  datahub_lints:
    diagnostics:
      const_service_constructor: true    # opt into a lint
      await_lifecycle_super: false       # opt out of a warning
      enum_config_requires_values: false # opt out of an error
```

Suppress a single report with a comment, prefixing the rule with the plugin
name:

```dart
// ignore: datahub_lints/prefer_instance_find
```

```dart
// ignore_for_file: datahub_lints/enum_config_requires_values
```


[DataHub]: https://datahubproject.net
[pub workspace]: https://dart.dev/tools/pub/workspaces
