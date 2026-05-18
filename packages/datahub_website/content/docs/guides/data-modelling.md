---
title: Data Modelling
index: 104
---

DataHub models data as **immutable Plain Old Dart Objects** (PODOs). Each data class gets a corresponding code-generated `DataBean` that captures field metadata, serialisation logic, and validation constraints at compile time.

## DataObject

Every data class mixes in `DataObject<T>` to gain deep equality and a standard JSON interface:

```dart
class User with DataObject<User> {
  @Id()
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  // Code-generated via datahub_codegen:
  static final $UserBean bean = $UserBean._();
  @override String get $$name => 'User';
  @override List<DataField<User, dynamic>> get $$fields => bean.fields;
  @override Map<String, dynamic> toJson() => { /* ... */ };
}
```

`DataObject` provides:
- Deep `==` and `hashCode` using all declared fields (including list / map / DateTime comparison)
- `toJson()` → `Map<String, dynamic>`

## DataBean

`DataBean<T>` holds all "static" metadata about a data class and is typically code-generated:

```dart
final class $UserBean extends DataBean<User> {
  $UserBean._() : super(
    name: 'User',
    fields: [idField, nameField, emailField],
    fromValues: (v) => User(id: v['id'], name: v['name'], email: v['email']),
    fromJson: (v, {String? name}) => /* codec decode */,
  );

  late final idField    = DataField<User, String>('id',    meta: [const Id()], /* ... */);
  late final nameField  = DataField<User, String>('name',  /* ... */);
  late final emailField = DataField<User, String>('email', /* ... */);
}
```

Useful `DataBean` methods:

| Method | Description |
|--------|-------------|
| `idField` | Returns the field annotated with `@Id()`, or `null` |
| `requireIdField` | Like `idField` but throws `MissingIdFieldError` when absent |
| `checkConstraints(obj)` | Returns `Map<DataField, List<DataFieldConstraint>>` of violations |
| `validateConstraints(obj)` | Throws `ValidationException` on any violation |
| `metaOfType<M>()` | First meta annotation of type `M` |
| `allMetaOfType<M>()` | All meta annotations of type `M` |

## Meta Annotations

Annotations placed on fields or classes communicate extra semantics to the framework:

### `@Id`

Marks the identity field of a data class. Required for repository operations that target a single record.

```dart
@Id()
final String id;

// Auto-generated IDs (e.g. UUIDs assigned by the database):
@Id(auto: true)
final String id;
```

### `@RelationId<T>`

Marks a foreign-key field pointing to another `DataObject` type:

```dart
@RelationId<Organization>()
final String organizationId;
```

Aperture uses this annotation to render navigation links in the UI.

### `@Meta`

Human-readable display hints:

```dart
@Meta(name: 'User', namePlural: 'Users', description: 'A registered user', icon: 0xe7fd)
class User with DataObject<User> { /* ... */ }

@Meta(name: 'Full name')
final String name;
```

### `@DataFieldConstraint` subclasses

Constraints are validated before persistence. Built-in constraints:

| Constraint | Type parameter | Description |
|-----------|---------------|-------------|
| `MinLengthConstraint(length:)` | `String?` | Minimum string length |
| `MaxLengthConstraint(length:)` | `String?` | Maximum string length |
| `RangeConstraint(min:, max:)` | `num?` | Numeric range (inclusive) |
| `RegExpConstraint(expression:)` | `String?` | Regex must match |
| `EnumConstraint(values:)` | `Enum?` | Value must be in list |
| `GeometryTypeConstraint(type:)` | `Geometry?` | Geometry must match type |
| `ElementConstraint(constraint:)` | `List<E>` | All list elements must pass |

```dart
@MinLengthConstraint(length: 2)
@MaxLengthConstraint(length: 50)
final String name;

@RangeConstraint(min: 0, max: 120)
final int? age;
```

Check constraints manually:
```dart
final violations = User.bean.checkConstraints(user);
if (violations.isNotEmpty) {
  for (final entry in violations.entries) {
    print('${entry.key.name}: ${entry.value.map((c) => c.toString()).join(', ')}');
  }
}
```

Or throw on any violation:
```dart
User.bean.validateConstraints(user); // throws ValidationException
```

## Filtering

`Filter` provides a composable, backend-agnostic query DSL. Filters are built from `DataField` references:

```dart
// Simple equality
final filter = Filter.equals(User.emailField, 'alice@example.com');

// Using extension methods on fields
final filter = User.emailField.contains('@example.com')
    .and(User.nameField.greaterThan('A'));

// Combining groups
final filter = Filter.andGroup([
  User.activeField.equals(true),
  Filter.orGroup([
    User.roleField.equals('admin'),
    User.roleField.equals('moderator'),
  ]),
]);
```

Available compare types: `equals`, `notEquals`, `contains`, `greaterThan`, `lessThan`, `greaterOrEqual`, `lessOrEqual`, `isIn`.

## Sorting

```dart
final sort = User.nameField.asc();

// Multi-field sort
final sort = User.createdField.desc()
    .followedBy([User.nameField.asc()]);
```

## DataEnum

Enums that implement `DataEnum` control their JSON representation via the `jsonValue` property:

```dart
enum Status implements DataEnum {
  active,
  inactive,
  suspended;

  @override
  String get jsonValue => switch (this) {
    active    => 'ACTIVE',
    inactive  => 'INACTIVE',
    suspended => 'SUSPENDED',
  };
}
```

This allows the Dart name and the serialised string to differ — useful when integrating with external APIs that use a different casing convention.

## Codec

The `JsonDataCodec` handles all serialisation between Dart types and JSON-compatible values:

| Dart type | JSON representation |
|-----------|-------------------|
| `String` | string |
| `int` / `double` | number |
| `bool` | boolean |
| `DateTime` | ISO 8601 string with timezone |
| `Duration` | integer milliseconds |
| `Uint8List` | base64-encoded string |
| `Enum` | `jsonValue` or `name` |
| `Geometry` | EWKB base64 string |
| `List<T>` | JSON array |
| `Map<String, T>` | JSON object |
| `DataObject` | nested JSON object |
