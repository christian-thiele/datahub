import 'package:datahub_postgres/schema.dart';

/// Compares the schema a migration history describes with the one a database
/// actually has.
///
/// This is deliberately a report and not a diff. Introspection cannot recover
/// everything a migration wrote - postgres reformats a view definition beyond
/// recognition, and a default comes back spelled its own way - so the answer
/// to "are these the same" is a list of findings a person reads, not a plan a
/// machine executes.
abstract final class SchemaDrift {
  /// Describes how [actual] differs from [expected].
  ///
  /// An empty result means the database matches the history in every respect
  /// that can be checked.
  static List<String> between({
    required SchemaSnapshot expected,
    required SchemaSnapshot actual,
  }) {
    final findings = <String>[];

    for (final relation in expected.relations.values) {
      final live = actual[relation.qualifiedName];
      if (live == null) {
        findings.add('${relation.kind} ${relation.qualifiedName} is missing.');
        continue;
      }

      if (live.kind != relation.kind) {
        findings.add(
          '${relation.qualifiedName} is a ${live.kind} but the history '
          'describes a ${relation.kind}.',
        );
        continue;
      }

      switch ((relation, live)) {
        case (final TableSnapshot expected, final TableSnapshot live):
          findings.addAll(_table(expected, live));
        case (final ViewSnapshot expected, final ViewSnapshot live):
          findings.addAll(_view(expected, live));
        default:
          break;
      }
    }

    // Relations the database has and the history does not are reported but
    // not treated as an error by callers - a database may legitimately hold
    // tables this application does not manage.
    for (final relation in actual.relations.values) {
      if (expected[relation.qualifiedName] == null) {
        findings.add(
          '${relation.kind} ${relation.qualifiedName} exists but is not part '
          'of the migration history.',
        );
      }
    }

    return findings;
  }

  static Iterable<String> _table(
    TableSnapshot expected,
    TableSnapshot actual,
  ) sync* {
    for (final attribute in expected.attributes) {
      final live = actual.attribute(attribute.name);
      if (live == null) {
        yield '${expected.qualifiedName}.${attribute.name} is missing.';
        continue;
      }

      if (live.type != attribute.type) {
        yield '${expected.qualifiedName}.${attribute.name} is ${live.type} '
            'but should be ${attribute.type}.';
      }
      if (live.notNull != attribute.notNull) {
        yield '${expected.qualifiedName}.${attribute.name} is '
            '${live.notNull ? 'NOT NULL' : 'nullable'} but should be '
            '${attribute.notNull ? 'NOT NULL' : 'nullable'}.';
      }
      if (live.primaryKey != attribute.primaryKey) {
        yield '${expected.qualifiedName}.${attribute.name} is '
            '${live.primaryKey ? '' : 'not '}a primary key but should '
            '${attribute.primaryKey ? '' : 'not '}be one.';
      }
      if (live.identity != attribute.identity) {
        yield '${expected.qualifiedName}.${attribute.name} is '
            '${live.identity ? '' : 'not '}an identity column but should '
            '${attribute.identity ? '' : 'not '}be one.';
      }
      if (live.defaultValue != attribute.defaultValue) {
        yield '${expected.qualifiedName}.${attribute.name} defaults to '
            '${live.defaultValue ?? 'nothing'} but should default to '
            '${attribute.defaultValue ?? 'nothing'}.';
      }
    }

    for (final attribute in actual.attributes) {
      if (expected.attribute(attribute.name) == null) {
        yield '${expected.qualifiedName}.${attribute.name} exists but is not '
            'part of the migration history.';
      }
    }

    for (final constraint in expected.constraints) {
      if (!actual.constraints.any((e) => e.name == constraint.name)) {
        yield 'Constraint ${constraint.name} on ${expected.qualifiedName} is '
            'missing.';
      }
    }
  }

  static Iterable<String> _view(
    ViewSnapshot expected,
    ViewSnapshot actual,
  ) sync* {
    final actualNames = actual.attributes.map((e) => e.name).toSet();
    final expectedNames = expected.attributes.map((e) => e.name).toSet();

    for (final name in expectedNames.difference(actualNames)) {
      yield '${expected.qualifiedName}.$name is missing from the view.';
    }
    for (final name in actualNames.difference(expectedNames)) {
      yield '${expected.qualifiedName}.$name is in the view but not in the '
          'migration history.';
    }

    // The view body itself is not compared: postgres stores its own
    // normalized rewrite of it, which never matches the text that created it.
  }
}
