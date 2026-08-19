import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

import 'postgresql_attribute.dart';
import 'postgresql_attribute_constraint.dart';
import 'postgresql_relation.dart';
import 'postgresql_table_constraint.dart';

/// An immutable, model-free description of a database schema.
///
/// A snapshot contains nothing but plain values, which makes it comparable,
/// JSON serializable and - most importantly - reproducible from a migration
/// history without access to a database or to the [DataBean]s it originated
/// from.
///
/// Snapshots come from three sources:
///
///  * [SchemaSnapshot.ofRelations] - the *desired* schema, derived from the
///    [DataBean]s of the application via [DataSchemaBuilder].
///  * replaying the changes of a migration history - the *expected* schema.
///  * [PostgresqlIntrospector] - the *actual* schema of a live database.
final class SchemaSnapshot {
  /// All relations of this snapshot by qualified name (`schema.name`).
  final Map<String, RelationSnapshot> relations;

  const SchemaSnapshot(this.relations);

  static const empty = SchemaSnapshot(<String, RelationSnapshot>{});

  factory SchemaSnapshot.of(Iterable<RelationSnapshot> relations) {
    return SchemaSnapshot({
      for (final relation in relations) relation.qualifiedName: relation,
    });
  }

  /// Derives a snapshot from the relations built by [DataSchemaBuilder].
  factory SchemaSnapshot.ofRelations(Iterable<PostgresqlRelation> relations) =>
      SchemaSnapshot.of(relations.map(RelationSnapshot.of));

  RelationSnapshot? operator [](String qualifiedName) =>
      relations[qualifiedName];

  Iterable<T> whereKind<T extends RelationSnapshot>() =>
      relations.values.whereType<T>();

  /// Returns a copy of this snapshot with [relation] added or replaced.
  SchemaSnapshot withRelation(RelationSnapshot relation) =>
      SchemaSnapshot({...relations, relation.qualifiedName: relation});

  /// Returns a copy of this snapshot without the relation [qualifiedName].
  SchemaSnapshot withoutRelation(String qualifiedName) =>
      SchemaSnapshot({...relations}..remove(qualifiedName));

  /// Returns a copy of this snapshot with [qualifiedName] replaced by the
  /// result of [update].
  ///
  /// Throws a [SchemaSnapshotException] when the relation does not exist or is
  /// not a table.
  SchemaSnapshot updateTable(
    String qualifiedName,
    TableSnapshot Function(TableSnapshot) update,
  ) {
    final relation = relations[qualifiedName];
    if (relation is! TableSnapshot) {
      throw SchemaSnapshotException(
        relation == null
            ? 'Relation "$qualifiedName" does not exist.'
            : 'Relation "$qualifiedName" is not a table.',
      );
    }

    return withRelation(update(relation));
  }

  List<Map<String, dynamic>> toJson() =>
      relations.values.map((e) => e.toJson()).toList();

  factory SchemaSnapshot.fromJson(List<dynamic> json) => SchemaSnapshot.of(
    json.map((e) => RelationSnapshot.fromJson(e as Map<String, dynamic>)),
  );

  @override
  bool operator ==(Object other) =>
      other is SchemaSnapshot && _mapEquals(relations, other.relations);

  @override
  int get hashCode => Object.hashAllUnordered(relations.values);
}

class SchemaSnapshotException implements Exception {
  final String message;

  const SchemaSnapshotException(this.message);

  @override
  String toString() => 'SchemaSnapshotException: $message';
}

sealed class RelationSnapshot {
  final String schemaName;
  final String name;

  const RelationSnapshot({required this.schemaName, required this.name});

  String get qualifiedName => '$schemaName.$name';

  /// The `kind` discriminator used in the JSON representation.
  String get kind;

  Map<String, dynamic> toJson();

  static RelationSnapshot of(PostgresqlRelation relation) => switch (relation) {
    final PostgresqlTable table => TableSnapshot.of(table),
    final PostgresqlView view => ViewSnapshot.of(view),
    final PostgresqlSequence sequence => SequenceSnapshot(
      schemaName: sequence.schemaName,
      name: sequence.name,
    ),
  };

  static RelationSnapshot fromJson(Map<String, dynamic> json) =>
      switch (json['kind']) {
        'table' => TableSnapshot.fromJson(json),
        'view' => ViewSnapshot.fromJson(json),
        'sequence' => SequenceSnapshot.fromJson(json),
        final kind => throw SchemaSnapshotException(
          'Unknown relation kind "$kind".',
        ),
      };
}

final class TableSnapshot extends RelationSnapshot {
  final List<AttributeSnapshot> attributes;
  final List<TableConstraintSnapshot> constraints;

  const TableSnapshot({
    required super.schemaName,
    required super.name,
    required this.attributes,
    this.constraints = const [],
  });

  @override
  String get kind => 'table';

  factory TableSnapshot.of(PostgresqlTable table) => TableSnapshot(
    schemaName: table.schemaName,
    name: table.name,
    attributes: table.attributes.map(AttributeSnapshot.of).toList(),
    constraints: [
      // A column level UNIQUE and a single column UNIQUE table constraint are
      // the same thing to postgres, and it names both the same way. Recording
      // only the table constraint form keeps one representation, so a unique
      // that moves between the two spellings is not seen as a change.
      for (final attribute in table.attributes)
        if (attribute.hasConstraint<UniqueConstraint>())
          TableConstraintSnapshot(
            name: TableConstraintSnapshot.defaultName(table.name, [
              attribute.name,
            ]),
            attributes: [attribute.name],
          ),
      ...table.constraints.map(
        (e) => TableConstraintSnapshot.of(table.name, e),
      ),
    ],
  );

  AttributeSnapshot? attribute(String name) =>
      attributes.where((e) => e.name == name).firstOrNull;

  TableSnapshot copyWith({
    List<AttributeSnapshot>? attributes,
    List<TableConstraintSnapshot>? constraints,
  }) => TableSnapshot(
    schemaName: schemaName,
    name: name,
    attributes: attributes ?? this.attributes,
    constraints: constraints ?? this.constraints,
  );

  @override
  Map<String, dynamic> toJson() => {
    'kind': kind,
    'schema': schemaName,
    'name': name,
    'attributes': attributes.map((e) => e.toJson()).toList(),
    if (constraints.isNotEmpty)
      'constraints': constraints.map((e) => e.toJson()).toList(),
  };

  factory TableSnapshot.fromJson(Map<String, dynamic> json) => TableSnapshot(
    schemaName: json['schema'] as String,
    name: json['name'] as String,
    attributes: (json['attributes'] as List)
        .map((e) => AttributeSnapshot.fromJson(e as Map<String, dynamic>))
        .toList(),
    constraints:
        (json['constraints'] as List?)
            ?.map(
              (e) =>
                  TableConstraintSnapshot.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        const [],
  );

  @override
  bool operator ==(Object other) =>
      other is TableSnapshot &&
      other.schemaName == schemaName &&
      other.name == name &&
      _unorderedEquals(other.attributes, attributes, (e) => e.name) &&
      _unorderedEquals(other.constraints, constraints, (e) => e.name);

  @override
  int get hashCode => Object.hash(
    schemaName,
    name,
    Object.hashAllUnordered(attributes),
    Object.hashAllUnordered(constraints),
  );
}

final class ViewSnapshot extends RelationSnapshot {
  /// The `SELECT` statement backing the view, as literal SQL.
  final String select;

  /// The attributes the view exposes.
  ///
  /// These are tracked so that a change to the underlying table is detected
  /// even when the `SELECT` itself is unchanged - a view built with `*`
  /// resolves its column list at creation time and does not pick up columns
  /// that are added later.
  final List<AttributeSnapshot> attributes;

  const ViewSnapshot({
    required super.schemaName,
    required super.name,
    required this.select,
    required this.attributes,
  });

  @override
  String get kind => 'view';

  factory ViewSnapshot.of(PostgresqlView view) => ViewSnapshot(
    schemaName: view.schemaName,
    name: view.name,
    select: view.select.toLiteralString(),
    attributes: [
      // A view column has a name and a type; the defaults and constraints of
      // the underlying table are not part of it and must not show up as drift.
      for (final attribute in view.attributes)
        AttributeSnapshot(name: attribute.name, type: attribute.type.name),
    ],
  );

  @override
  Map<String, dynamic> toJson() => {
    'kind': kind,
    'schema': schemaName,
    'name': name,
    'select': select,
    'attributes': attributes.map((e) => e.toJson()).toList(),
  };

  factory ViewSnapshot.fromJson(Map<String, dynamic> json) => ViewSnapshot(
    schemaName: json['schema'] as String,
    name: json['name'] as String,
    select: json['select'] as String,
    attributes: (json['attributes'] as List)
        .map((e) => AttributeSnapshot.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  @override
  bool operator ==(Object other) =>
      other is ViewSnapshot &&
      other.schemaName == schemaName &&
      other.name == name &&
      other.select == select &&
      _unorderedEquals(other.attributes, attributes, (e) => e.name);

  @override
  int get hashCode => Object.hash(
    schemaName,
    name,
    select,
    Object.hashAllUnordered(attributes),
  );
}

final class SequenceSnapshot extends RelationSnapshot {
  const SequenceSnapshot({required super.schemaName, required super.name});

  @override
  String get kind => 'sequence';

  @override
  Map<String, dynamic> toJson() => {
    'kind': kind,
    'schema': schemaName,
    'name': name,
  };

  factory SequenceSnapshot.fromJson(Map<String, dynamic> json) =>
      SequenceSnapshot(
        schemaName: json['schema'] as String,
        name: json['name'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is SequenceSnapshot &&
      other.schemaName == schemaName &&
      other.name == name;

  @override
  int get hashCode => Object.hash(schemaName, name);
}

final class AttributeSnapshot {
  final String name;

  /// The postgres type name, see [PostgresqlDataType.name].
  final String type;

  final bool notNull;
  final bool primaryKey;

  /// Whether the attribute is declared `GENERATED ALWAYS AS IDENTITY`.
  final bool identity;

  /// The `DEFAULT` expression as literal SQL, if any.
  final String? defaultValue;

  const AttributeSnapshot({
    required this.name,
    required this.type,
    this.notNull = false,
    this.primaryKey = false,
    this.identity = false,
    this.defaultValue,
  });

  factory AttributeSnapshot.of(PostgresqlAttribute attribute) {
    final primaryKey = attribute.constraints
        .whereType<PrimaryKeyConstraint>()
        .firstOrNull;
    final defaultConstraint = attribute.constraints
        .whereType<DefaultConstraint>()
        .firstOrNull;

    // The auto flag of a primary key is expanded here into the two things it
    // actually means in DDL, so that a snapshot describes the column and not
    // the shorthand that produced it.
    final isIdentity =
        (primaryKey?.auto ?? false) &&
        (attribute.type is PostgresqlInt || attribute.type is PostgresqlSerial);
    final autoUuid =
        (primaryKey?.auto ?? false) && attribute.type is PostgresqlString;

    return AttributeSnapshot(
      name: attribute.name,
      type: attribute.type.name,
      notNull: attribute.hasConstraint<NotNullConstraint>(),
      primaryKey: primaryKey != null,
      identity: isIdentity,
      defaultValue:
          defaultConstraint?.value.toLiteralString() ??
          (autoUuid ? 'gen_random_uuid()' : null),
    );
  }

  AttributeSnapshot copyWith({
    String? type,
    bool? notNull,
    Object? defaultValue = _unset,
  }) => AttributeSnapshot(
    name: name,
    type: type ?? this.type,
    notNull: notNull ?? this.notNull,
    primaryKey: primaryKey,
    identity: identity,
    defaultValue: identical(defaultValue, _unset)
        ? this.defaultValue
        : defaultValue as String?,
  );

  /// The column declaration used inside `CREATE TABLE` and `ADD COLUMN`.
  Sql toDeclarationSql() => Sql.join([
    RawSql('${Sql.escapeName(name)} $type'),
    if (primaryKey) RawSql(' PRIMARY KEY'),
    if (identity) RawSql(' GENERATED ALWAYS AS IDENTITY'),
    if (notNull) RawSql(' NOT NULL'),
    if (defaultValue case final defaultValue?) RawSql(' DEFAULT $defaultValue'),
  ]);

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    if (notNull) 'notNull': true,
    if (primaryKey) 'primaryKey': true,
    if (identity) 'identity': true,
    if (defaultValue case final defaultValue?) 'default': defaultValue,
  };

  factory AttributeSnapshot.fromJson(Map<String, dynamic> json) =>
      AttributeSnapshot(
        name: json['name'] as String,
        type: json['type'] as String,
        notNull: json['notNull'] as bool? ?? false,
        primaryKey: json['primaryKey'] as bool? ?? false,
        identity: json['identity'] as bool? ?? false,
        defaultValue: json['default'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is AttributeSnapshot &&
      other.name == name &&
      other.type == type &&
      other.notNull == notNull &&
      other.primaryKey == primaryKey &&
      other.identity == identity &&
      other.defaultValue == defaultValue;

  @override
  int get hashCode =>
      Object.hash(name, type, notNull, primaryKey, identity, defaultValue);

  @override
  String toString() => toDeclarationSql().toLiteralString();
}

final class TableConstraintSnapshot {
  final String name;
  final List<String> attributes;
  final bool nullsNotDistinct;

  const TableConstraintSnapshot({
    required this.name,
    required this.attributes,
    this.nullsNotDistinct = false,
  });

  factory TableConstraintSnapshot.of(
    String relationName,
    PostgresqlTableConstraint constraint,
  ) => switch (constraint) {
    UniqueTableConstraint(:final attributes, :final nullsNotDistinct) =>
      TableConstraintSnapshot(
        name: defaultName(relationName, attributes.map((e) => e.name)),
        attributes: attributes.map((e) => e.name).toList(),
        nullsNotDistinct: nullsNotDistinct,
      ),
  };

  /// The name postgres itself would assign to an unnamed unique constraint.
  ///
  /// Deriving the same name means a constraint created by an older
  /// `CREATE TABLE` (which never named its constraints) can still be found and
  /// dropped by a later migration.
  static String defaultName(
    String relationName,
    Iterable<String> attributeNames,
  ) => '${relationName}_${attributeNames.join('_')}_key';

  Sql toDeclarationSql() => Sql.join([
    RawSql('CONSTRAINT ${Sql.escapeName(name)} UNIQUE '),
    if (nullsNotDistinct) RawSql('NULLS NOT DISTINCT '),
    RawSql('(${attributes.map(Sql.escapeName).join(', ')})'),
  ]);

  Map<String, dynamic> toJson() => {
    'name': name,
    'attributes': attributes,
    if (nullsNotDistinct) 'nullsNotDistinct': true,
  };

  factory TableConstraintSnapshot.fromJson(Map<String, dynamic> json) =>
      TableConstraintSnapshot(
        name: json['name'] as String,
        attributes: (json['attributes'] as List).cast<String>(),
        nullsNotDistinct: json['nullsNotDistinct'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      other is TableConstraintSnapshot &&
      other.name == name &&
      other.nullsNotDistinct == nullsNotDistinct &&
      _stringListEquals(other.attributes, attributes);

  @override
  int get hashCode =>
      Object.hash(name, nullsNotDistinct, Object.hashAll(attributes));

  @override
  String toString() => toDeclarationSql().toLiteralString();
}

const _unset = Object();

bool _stringListEquals(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// Compares two collections by key, ignoring order.
///
/// Column order is not something this migration system manages - a column
/// added by `ALTER TABLE` always lands at the end, while the model lists it
/// wherever the field is declared - so comparing schemas by position would
/// report drift that no migration could ever resolve.
bool _unorderedEquals<T, K>(List<T> a, List<T> b, K Function(T) key) {
  if (a.length != b.length) {
    return false;
  }
  final byKey = {for (final element in b) key(element): element};
  for (final element in a) {
    if (byKey[key(element)] != element) {
      return false;
    }
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) {
    return false;
  }
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}
