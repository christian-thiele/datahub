import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';

/// A single, reversible-in-principle step from one [SchemaSnapshot] to another.
///
/// A change knows three things, and all three have to stay in agreement:
///
///  * [apply] - how it transforms a snapshot. This is what makes a migration
///    history replayable without a database.
///  * [toSql] - the DDL that performs it.
///  * [toJson] - how it is recorded in the header of a migration file.
sealed class SchemaChange {
  const SchemaChange();

  /// The discriminator used in the JSON representation.
  String get op;

  /// Whether applying this change can lose data.
  bool get isDestructive => false;

  /// Why this change cannot be applied as generated, if it cannot.
  ///
  /// A non-null reason marks the containing migration as requiring review: it
  /// describes a change that is well-defined against an empty table but not
  /// against one that already holds rows.
  String? get reviewReason => null;

  /// A one-line, human readable description used in plans and drift reports.
  String describe();

  /// Returns [snapshot] with this change applied.
  SchemaSnapshot apply(SchemaSnapshot snapshot);

  /// The statements performing this change.
  List<Sql> toSql();

  Map<String, dynamic> toJson();

  @override
  String toString() => describe();

  static SchemaChange fromJson(Map<String, dynamic> json) =>
      switch (json['op']) {
        'createRelation' => CreateRelation.fromJson(json),
        'dropRelation' => DropRelation.fromJson(json),
        'addAttribute' => AddAttribute.fromJson(json),
        'dropAttribute' => DropAttribute.fromJson(json),
        'alterAttributeType' => AlterAttributeType.fromJson(json),
        'alterAttributeNullability' => AlterAttributeNullability.fromJson(json),
        'alterAttributeDefault' => AlterAttributeDefault.fromJson(json),
        'addTableConstraint' => AddTableConstraint.fromJson(json),
        'dropTableConstraint' => DropTableConstraint.fromJson(json),
        final op => throw SchemaSnapshotException(
          'Unknown schema change op "$op".',
        ),
      };

  static (String schemaName, String name) splitQualifiedName(String qualified) {
    final separator = qualified.indexOf('.');
    if (separator < 0) {
      throw SchemaSnapshotException(
        'Relation name "$qualified" is not schema qualified.',
      );
    }
    return (
      qualified.substring(0, separator),
      qualified.substring(separator + 1),
    );
  }
}

final class CreateRelation extends SchemaChange {
  final RelationSnapshot relation;

  const CreateRelation(this.relation);

  @override
  String get op => 'createRelation';

  @override
  String describe() => 'create ${relation.kind} ${relation.qualifiedName}';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) =>
      snapshot.withRelation(relation);

  @override
  List<Sql> toSql() => [SqlCreateRelation(relation)];

  @override
  Map<String, dynamic> toJson() => {'op': op, 'relation': relation.toJson()};

  factory CreateRelation.fromJson(Map<String, dynamic> json) => CreateRelation(
    RelationSnapshot.fromJson(json['relation'] as Map<String, dynamic>),
  );
}

final class DropRelation extends SchemaChange {
  final String relation;
  final String kind;

  const DropRelation(this.relation, this.kind);

  @override
  String get op => 'dropRelation';

  @override
  bool get isDestructive => kind != 'view';

  @override
  String describe() => 'drop $kind $relation';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) =>
      snapshot.withoutRelation(relation);

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [SqlDropRelation(schemaName: schemaName, name: name, kind: kind)];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'kind': kind,
  };

  factory DropRelation.fromJson(Map<String, dynamic> json) =>
      DropRelation(json['relation'] as String, json['kind'] as String);
}

final class AddAttribute extends SchemaChange {
  final String relation;
  final AttributeSnapshot attribute;

  const AddAttribute(this.relation, this.attribute);

  @override
  String get op => 'addAttribute';

  @override
  String? get reviewReason =>
      attribute.notNull && attribute.defaultValue == null && !attribute.identity
      ? 'Column "${attribute.name}" is NOT NULL without a default. '
            'Existing rows need a backfill before the constraint can be set.'
      : null;

  @override
  String describe() => 'add $relation.${attribute.name} ${attribute.type}';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) => snapshot.updateTable(
    relation,
    (table) => table.copyWith(attributes: [...table.attributes, attribute]),
  );

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [
      SqlAlterTable(
        schemaName: schemaName,
        name: name,
        actions: [SqlAddColumn(attribute)],
      ),
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'attribute': attribute.toJson(),
  };

  factory AddAttribute.fromJson(Map<String, dynamic> json) => AddAttribute(
    json['relation'] as String,
    AttributeSnapshot.fromJson(json['attribute'] as Map<String, dynamic>),
  );
}

final class DropAttribute extends SchemaChange {
  final String relation;
  final String attribute;

  const DropAttribute(this.relation, this.attribute);

  @override
  String get op => 'dropAttribute';

  @override
  bool get isDestructive => true;

  @override
  String describe() => 'drop $relation.$attribute';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) => snapshot.updateTable(
    relation,
    (table) => table.copyWith(
      attributes: table.attributes.where((e) => e.name != attribute).toList(),
    ),
  );

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [
      SqlAlterTable(
        schemaName: schemaName,
        name: name,
        actions: [SqlDropColumn(attribute)],
      ),
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'attribute': attribute,
  };

  factory DropAttribute.fromJson(Map<String, dynamic> json) =>
      DropAttribute(json['relation'] as String, json['attribute'] as String);
}

final class AlterAttributeType extends SchemaChange {
  final String relation;
  final String attribute;
  final String type;
  final String previousType;

  const AlterAttributeType(
    this.relation,
    this.attribute, {
    required this.type,
    required this.previousType,
  });

  @override
  String get op => 'alterAttributeType';

  @override
  bool get isDestructive => true;

  @override
  String? get reviewReason =>
      'Cast of "$relation.$attribute" from $previousType to $type may fail or '
      'lose precision for existing rows.';

  @override
  String describe() => 'alter $relation.$attribute type $previousType -> $type';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) => snapshot.updateTable(
    relation,
    (table) => table.copyWith(
      attributes: [
        for (final a in table.attributes)
          if (a.name == attribute) a.copyWith(type: type) else a,
      ],
    ),
  );

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [
      SqlAlterTable(
        schemaName: schemaName,
        name: name,
        actions: [SqlAlterColumnType(attribute, type)],
      ),
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'attribute': attribute,
    'type': type,
    'previousType': previousType,
  };

  factory AlterAttributeType.fromJson(Map<String, dynamic> json) =>
      AlterAttributeType(
        json['relation'] as String,
        json['attribute'] as String,
        type: json['type'] as String,
        previousType: json['previousType'] as String,
      );
}

final class AlterAttributeNullability extends SchemaChange {
  final String relation;
  final String attribute;
  final bool notNull;

  const AlterAttributeNullability(
    this.relation,
    this.attribute, {
    required this.notNull,
  });

  @override
  String get op => 'alterAttributeNullability';

  @override
  String? get reviewReason => notNull
      ? 'Existing rows with a NULL "$relation.$attribute" have to be filled '
            'before NOT NULL can be set.'
      : null;

  @override
  String describe() =>
      '${notNull ? 'set' : 'drop'} NOT NULL on $relation.$attribute';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) => snapshot.updateTable(
    relation,
    (table) => table.copyWith(
      attributes: [
        for (final a in table.attributes)
          if (a.name == attribute) a.copyWith(notNull: notNull) else a,
      ],
    ),
  );

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [
      SqlAlterTable(
        schemaName: schemaName,
        name: name,
        actions: [SqlAlterColumnNotNull(attribute, notNull)],
      ),
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'attribute': attribute,
    'notNull': notNull,
  };

  factory AlterAttributeNullability.fromJson(Map<String, dynamic> json) =>
      AlterAttributeNullability(
        json['relation'] as String,
        json['attribute'] as String,
        notNull: json['notNull'] as bool,
      );
}

final class AlterAttributeDefault extends SchemaChange {
  final String relation;
  final String attribute;
  final String? defaultValue;

  const AlterAttributeDefault(
    this.relation,
    this.attribute, {
    required this.defaultValue,
  });

  @override
  String get op => 'alterAttributeDefault';

  @override
  String describe() => defaultValue == null
      ? 'drop default on $relation.$attribute'
      : 'set default on $relation.$attribute to $defaultValue';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) => snapshot.updateTable(
    relation,
    (table) => table.copyWith(
      attributes: [
        for (final a in table.attributes)
          if (a.name == attribute)
            a.copyWith(defaultValue: defaultValue)
          else
            a,
      ],
    ),
  );

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [
      SqlAlterTable(
        schemaName: schemaName,
        name: name,
        actions: [SqlAlterColumnDefault(attribute, defaultValue)],
      ),
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'attribute': attribute,
    'default': defaultValue,
  };

  factory AlterAttributeDefault.fromJson(Map<String, dynamic> json) =>
      AlterAttributeDefault(
        json['relation'] as String,
        json['attribute'] as String,
        defaultValue: json['default'] as String?,
      );
}

final class AddTableConstraint extends SchemaChange {
  final String relation;
  final TableConstraintSnapshot constraint;

  const AddTableConstraint(this.relation, this.constraint);

  @override
  String get op => 'addTableConstraint';

  @override
  String? get reviewReason =>
      'Existing rows have to satisfy ${constraint.name} before it can be '
      'added.';

  @override
  String describe() => 'add constraint ${constraint.name} on $relation';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) => snapshot.updateTable(
    relation,
    (table) => table.copyWith(constraints: [...table.constraints, constraint]),
  );

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [
      SqlAlterTable(
        schemaName: schemaName,
        name: name,
        actions: [SqlAddTableConstraint(constraint)],
      ),
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'constraint': constraint.toJson(),
  };

  factory AddTableConstraint.fromJson(Map<String, dynamic> json) =>
      AddTableConstraint(
        json['relation'] as String,
        TableConstraintSnapshot.fromJson(
          json['constraint'] as Map<String, dynamic>,
        ),
      );
}

final class DropTableConstraint extends SchemaChange {
  final String relation;
  final String constraint;

  const DropTableConstraint(this.relation, this.constraint);

  @override
  String get op => 'dropTableConstraint';

  @override
  String describe() => 'drop constraint $constraint on $relation';

  @override
  SchemaSnapshot apply(SchemaSnapshot snapshot) => snapshot.updateTable(
    relation,
    (table) => table.copyWith(
      constraints: table.constraints
          .where((e) => e.name != constraint)
          .toList(),
    ),
  );

  @override
  List<Sql> toSql() {
    final (schemaName, name) = SchemaChange.splitQualifiedName(relation);
    return [
      SqlAlterTable(
        schemaName: schemaName,
        name: name,
        actions: [SqlDropTableConstraint(constraint)],
      ),
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
    'op': op,
    'relation': relation,
    'constraint': constraint,
  };

  factory DropTableConstraint.fromJson(Map<String, dynamic> json) =>
      DropTableConstraint(
        json['relation'] as String,
        json['constraint'] as String,
      );
}
