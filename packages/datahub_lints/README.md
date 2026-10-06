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

The quickest way in is the recommended set that ships with `datahub`, which
switches on every rule including the opt-in lints. Include it from your
`analysis_options.yaml`:

```yaml
include: package:datahub/recommended.yaml
```

Analysis options take a single `include`. If you already include another set,
such as `package:lints/recommended.yaml`, list both:

```yaml
include:
  - package:lints/recommended.yaml
  - package:datahub/recommended.yaml
```

To pick rules yourself instead, declare the plugin in a top-level `plugins`
section:

```yaml
plugins:
  datahub_lints: ^0.18.0-dev.2
```

Then only warnings and errors are on; see [Configuration](#configuration) for
switching on lints.

Either way there is no separate command to run. The rules show up in your IDE
and in `dart analyze`.

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
| 💡 | lint | off, switch it on under `diagnostics`; on in the recommended set |

#### Services and dependency injection

| Rule | Reports | Fix |
|------|---------|-----|
| `prefer_instance_find` ⚠️ | `finder.find()` inside a `ServiceInstance`, which resolves through the caller's zone instead of the service's own context | `find(finder)` |
| `prefer_instance_read` ⚠️ | `config.read()` inside a `ServiceInstance` | `read(config)` |
| `avoid_zone_context_in_service` ⚠️ | `Context.ofZone()`, `Context.zoneFind()` and friends inside a `ServiceInstance` | `find(x)` / `read(x)` |
| `await_lifecycle_super` ⚠️ | `super.initialize()` / `super.dispose()` left unawaited; both return `FutureOr<void>` | add `await` |
| `super_initialize_first` ⚠️ | `super.initialize()` that is not the first statement of the override | move it to the top |
| `super_dispose_last` ⚠️ | `super.dispose()` that is not the last statement of the override | move it to the bottom |
| `avoid_injection_in_initializer` ⚠️ | `find()`, `read()` or `context` in a `ServiceInstance` constructor, where the context is not assigned yet | — |
| `const_service_constructor` 💡 | a `Service` implementation without a const constructor | add `const` |

#### Configuration

| Rule | Reports | Fix |
|------|---------|-----|
| `enum_config_requires_values` 🛑 | `Config<SomeEnum>('path')` without `values:` | add `values: SomeEnum.values` |
| `config_requires_default` ⚠️ | a `Config` with no `defaultValue:` whose path is missing from the package's `resources/defaults.yaml` | — |

#### Data classes

| Rule | Reports | Fix |
|------|---------|-----|
| `data_class_requires_part` ⚠️ | a `@Data()` class in a library without its `part '….g.dart';` | add the directive |
| `data_class_extends_generated` ⚠️ | a `@Data()` class that does not extend `$Name` | add the superclass |
| `data_class_const_constructor` ⚠️ | a `@Data()` class without an unnamed const constructor, or one taking positional parameters | add `const` / write the constructor |

#### Filters and sorts

| Rule | Reports | Fix |
|------|---------|-----|
| `reducible_filter_group` 💡 | a `Filter.andGroup` / `orGroup` / `FilterGroup` / `a.and(b)` that is empty, holds a single filter, nests a group of the same kind, or contains an operand without effect (`Filter.empty` in an `and`, `Filter.nothing` in an `or`) | simplify the group |
| `reducible_sort_group` 💡 | a `Sort.followedBy` / `SortGroup` that is empty, holds a single sort, nests another group, or contains `Sort.empty` | simplify the group |
| `constant_filter_group` ⚠️ | `Filter.empty` in an `or` group or `Filter.nothing` in an `and` group, which decides the group whatever the other operands are | — |

#### Aperture

| Rule | Reports | Fix |
|------|---------|-----|
| `aperture_relation_requires_relation_id` ⚠️ | `@ApertureRelation<T>()` where `T` has no field annotated `@RelationId<Owner>()` | — |
| `aperture_relation_requires_resource` ⚠️ | `@ApertureRelation<R>()` on a resource's class where `R` is not registered as an `ApertureResource` in the same `ApertureApi` | — |

#### PostgreSQL

Checked where a revisable repository is declared: the `bean:` of a
`PostgresqlRevisableRepositoryService`, or a `PostgresqlRevisableRepository`
mixin application. Both fail when the repository initializes.

| Rule | Reports | Fix |
|------|---------|-----|
| `revisable_bean_requires_id` ⚠️ | a data class without an `@Id()` field of type `int` or `String` (non-nullable), which revisions are keyed by | — |
| `revisable_reserved_column` ⚠️ | a data class field whose column is one the repository uses for revision metadata (`sys_version`, `sys_from`, `sys_to`, …) | — |

#### Scheduler

Mirror `Schedule.validate()` and `Scheduler.registerSchedule()`, which throw
while the application starts. Only values known statically are checked.

| Rule | Reports | Fix |
|------|---------|-----|
| `schedule_requires_name` ⚠️ | a `Schedule` with an empty name | — |
| `schedule_requires_positive_interval` ⚠️ | a `Schedule.every` whose `interval` is zero or negative | — |
| `schedule_time_out_of_range` ⚠️ | a `Schedule.daily` / `Schedule.monthly` with an `hour` outside 0–23, a `minute` outside 0–59 or a `day` outside 1–31 | — |
| `duplicate_schedule_name` ⚠️ | two schedules with the same name in one list of components | — |

#### Workflows

Mirror `WorkflowService.validate()`, which throws when the workflow
initializes. Step rules check `OnEnter` / `OnSignal` wherever they are
declared; workflow rules check the `steps:` list literal of a
`WorkflowService`.

| Rule | Reports | Fix |
|------|---------|-----|
| `workflow_requires_steps` ⚠️ | a `WorkflowService` with an empty `steps` list | — |
| `duplicate_workflow_step_name` ⚠️ | two steps of a workflow with the same name, including names derived from the state and delay of an `OnEnter` | — |
| `duplicate_workflow_signal` ⚠️ | two `OnSignal` steps of a workflow for the same signal | — |
| `workflow_step_negative_delay` ⚠️ | an `OnEnter` with a negative `after` | — |
| `workflow_step_delay_and_time` ⚠️ | an `OnEnter` with both `after` and `at` | — |
| `workflow_step_own_failure_state` ⚠️ | an `OnEnter` whose `failureState` is the state it runs in | — |
| `workflow_signal_requires_accept` ⚠️ | an `OnSignal` with an empty `accept` list | — |
| `workflow_signal_expires_immediately` ⚠️ | an `OnSignal` whose `expireAfter` is zero or negative | — |
| `workflow_signal_not_for_element` ⚠️ | an `OnSignal` whose signal does not implement `WorkflowSignal<T>` for the element type of the workflow | — |

### Assists

Available from the IDE at the node listed below (Alt+Enter in IntelliJ, Ctrl+.
in VS Code).

| Assist | Offered on | Generates |
|--------|-----------|-----------|
| Generate ServiceInstance | a `Service` without `createInstance()` | the `createInstance()` override and the matching `ServiceInstance` class |
| Convert to DataHub data class | a plain class | `@Data()`, the `$Name` superclass, the part directive and a const constructor over the fields |
| Add Find injection field | a `Service` | a `final Find<T> name;` field and its constructor parameter |
| Convert to 'Filter.andGroup' / 'Filter.orGroup' | an `a.and(b).and(c)` / `a.or(b)` chain | `Filter.andGroup([a, b, c])` |

### Configuration

Switch any rule on or off under `diagnostics`:

```yaml
plugins:
  datahub_lints:
    version: ^0.18.0-dev.2
    diagnostics:
      const_service_constructor: true    # opt into a lint
      await_lifecycle_super: false       # opt out of a warning
      enum_config_requires_values: false # opt out of an error
```

The analyzer does not merge this section with one from an included file: a
`plugins: datahub_lints:` entry of your own replaces the recommended set
entirely, and `analyzer: errors:` does not apply to plugin rules. To adjust the
recommended set, drop the include and copy its `diagnostics` from
[`package:datahub/recommended.yaml`](https://github.com/christian-thiele/datahub/blob/main/packages/datahub/lib/recommended.yaml) into your own entry.

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
