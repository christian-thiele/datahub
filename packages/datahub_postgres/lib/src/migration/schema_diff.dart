import 'package:datahub_postgres/schema.dart';

import 'schema_change.dart';

class SchemaDiffException implements Exception {
  final String message;

  const SchemaDiffException(this.message);

  @override
  String toString() => 'SchemaDiffException: $message';
}

/// Computes the [SchemaChange]s that turn one [SchemaSnapshot] into another.
abstract final class SchemaDiff {
  /// Returns the ordered list of changes that transform [from] into [to].
  ///
  /// The order is chosen so that every statement is legal at the point it
  /// runs: views that are about to change are removed first (postgres refuses
  /// to drop or retype a column a view depends on), then the tables are
  /// brought into shape, then the views are put back.
  static List<SchemaChange> between(SchemaSnapshot from, SchemaSnapshot to) {
    final staleViews = <ViewSnapshot>[];
    final freshViews = <ViewSnapshot>[];

    for (final view in from.whereKind<ViewSnapshot>()) {
      if (to[view.qualifiedName] != view) {
        staleViews.add(view);
      }
    }

    for (final view in to.whereKind<ViewSnapshot>()) {
      if (from[view.qualifiedName] != view) {
        freshViews.add(view);
      }
    }

    return [
      for (final view in staleViews) DropRelation(view.qualifiedName, 'view'),

      for (final sequence in to.whereKind<SequenceSnapshot>())
        if (from[sequence.qualifiedName] == null) CreateRelation(sequence),

      for (final table in to.whereKind<TableSnapshot>())
        if (from[table.qualifiedName] == null) CreateRelation(table),

      for (final table in to.whereKind<TableSnapshot>())
        if (from[table.qualifiedName] case final TableSnapshot previous)
          ..._diffTable(previous, table),

      for (final table in from.whereKind<TableSnapshot>())
        if (to[table.qualifiedName] == null)
          DropRelation(table.qualifiedName, 'table'),

      for (final sequence in from.whereKind<SequenceSnapshot>())
        if (to[sequence.qualifiedName] == null)
          DropRelation(sequence.qualifiedName, 'sequence'),

      for (final view in freshViews) CreateRelation(view),
    ];
  }

  static Iterable<SchemaChange> _diffTable(
    TableSnapshot from,
    TableSnapshot to,
  ) sync* {
    final relation = to.qualifiedName;

    // Constraints are dropped before the columns they cover, and added after
    // the columns they cover exist.
    for (final constraint in from.constraints) {
      if (!to.constraints.any((e) => e == constraint)) {
        yield DropTableConstraint(relation, constraint.name);
      }
    }

    for (final attribute in to.attributes) {
      if (from.attribute(attribute.name) == null) {
        yield AddAttribute(relation, attribute);
      }
    }

    for (final attribute in to.attributes) {
      final previous = from.attribute(attribute.name);
      if (previous == null || previous == attribute) {
        continue;
      }

      if (previous.type != attribute.type) {
        yield AlterAttributeType(
          relation,
          attribute.name,
          type: attribute.type,
          previousType: previous.type,
        );
      }

      if (previous.notNull != attribute.notNull) {
        yield AlterAttributeNullability(
          relation,
          attribute.name,
          notNull: attribute.notNull,
        );
      }

      if (previous.defaultValue != attribute.defaultValue) {
        yield AlterAttributeDefault(
          relation,
          attribute.name,
          defaultValue: attribute.defaultValue,
        );
      }

      // Identity and primary key changes are deliberately not generated:
      // rewriting a primary key on a populated table is a decision, not a
      // detail, and silently emitting nothing would let the model and the
      // database drift apart without a trace.
      if (previous.primaryKey != attribute.primaryKey ||
          previous.identity != attribute.identity) {
        throw SchemaDiffException(
          'Cannot generate a migration for the primary key change on '
          '"$relation"."${attribute.name}" '
          '(primary key ${previous.primaryKey} -> ${attribute.primaryKey}, '
          'identity ${previous.identity} -> ${attribute.identity}). '
          'Write this migration by hand with "migrate new <name> --empty".',
        );
      }
    }

    for (final attribute in from.attributes) {
      if (to.attribute(attribute.name) == null) {
        yield DropAttribute(relation, attribute.name);
      }
    }

    for (final constraint in to.constraints) {
      if (!from.constraints.any((e) => e == constraint)) {
        yield AddTableConstraint(relation, constraint);
      }
    }
  }
}
