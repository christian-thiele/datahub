import 'dart:async';

import '../service_host.dart';

/// A service a migration command needs once it talks to a database.
///
/// A [MigrationHost] initializes these only for the commands that actually
/// connect - `migrate plan` and `migrate new` answer their question from the
/// data model and the migration files alone, and must work with no database
/// running at all.
abstract interface class MigrationDependency implements Service {}

/// A service that provides `migrate` subcommands.
///
/// Always initialized by a [MigrationHost], since it is what the command is
/// run against. Everything not marked as this or as a [MigrationDependency] -
/// HTTP servers, consumers, schedulers - stays uninitialized, so `datahub
/// migrate` never opens a port just to describe a schema.
abstract interface class MigrationToolService implements Service {}

/// A service that implements the `migrate` subcommands for a database.
///
/// The CLI is deliberately thin: it builds the component tree of the
/// application - which is where the data model, the connection settings and
/// the migration directory are all declared - and hands the parsed command to
/// whichever service knows how to carry it out.
abstract interface class SchemaMigrationTool {
  /// A name for this tool, used when a project has more than one.
  String get migrationToolName;

  /// Runs [command] and returns a process exit code.
  Future<int> runMigrationCommand(MigrationCommand command);
}

/// A parsed `migrate` invocation.
class MigrationCommand {
  static const keyword = 'migrate';

  static const names = {'new', 'plan', 'status', 'apply', 'verify', 'baseline'};

  final String name;

  /// The positional argument, if the command takes one (`migrate new <name>`).
  final String? argument;

  final Set<String> flags;

  const MigrationCommand({
    required this.name,
    this.argument,
    this.flags = const {},
  });

  bool has(String flag) => flags.contains(flag);

  /// Whether carrying out this command requires a database connection.
  ///
  /// Generating and planning migrations deliberately does not: the schema they
  /// diff against is replayed from the migration files, so they work in CI and
  /// on a laptop with nothing running.
  bool get needsDatabase => name != 'new' && name != 'plan';

  /// Parses [arguments] if they invoke a migration command.
  ///
  /// Returns `null` when they do not, which is how [runApp] tells an
  /// application start from a CLI invocation.
  static MigrationCommand? tryParse(List<String> arguments) {
    if (arguments.firstOrNull != keyword) {
      return null;
    }

    String? name;
    String? argument;
    final flags = <String>{};

    for (var i = 1; i < arguments.length; i++) {
      final argument_ = arguments[i];

      if (argument_.startsWith('--')) {
        flags.add(argument_.substring(2));
        continue;
      }

      // Config options keep their value, which must not be mistaken for the
      // command's own positional argument.
      if (argument_ == '-c' || argument_ == '-f') {
        i++;
        continue;
      }
      if (argument_.startsWith('-')) {
        continue;
      }

      if (name == null) {
        name = argument_;
      } else {
        argument ??= argument_;
      }
    }

    return MigrationCommand(
      name: name ?? 'status',
      argument: argument,
      flags: flags,
    );
  }
}
