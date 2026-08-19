import 'dart:io';

import 'package:datahub/src/config/config_arguments.dart';
import 'package:datahub/src/services/key_service/key_service.dart';
import 'package:datahub/telemetry.dart';

import 'migration/schema_migration_tool.dart';
import 'service_host.dart';

/// Builds an application's component tree to run a `migrate` command against
/// it, without starting the application.
///
/// Only the services a migration actually needs are initialized - see
/// [MigrationDependency]. Everything else keeps its place in the tree but is
/// never instantiated, so running `datahub migrate plan` does not bind a port,
/// and running it in a project without a database does not try to connect to
/// one.
class MigrationHost extends ServiceHost {
  final List<Component> components;
  final List<String> arguments;
  final Map<String, dynamic> initialConfig;

  MigrationHost({
    required this.components,
    required this.arguments,
    required this.initialConfig,
    super.environmentVariables,
  });

  @override
  HostPurpose get purpose => HostPurpose.tool;

  MigrationCommand? _command;

  @override
  bool shouldInitialize(Service service) =>
      service is TelemetryService ||
      service is KeyService ||
      service is MigrationToolService ||
      (service is MigrationDependency && (_command?.needsDatabase ?? true));

  @override
  Component buildRoot() {
    return Scope(
      name: 'root',
      components: [
        Scope(name: 'internal', components: [TelemetryService(), KeyService()]),
        Scope(name: 'application', components: components),
      ],
    );
  }

  @override
  Future<void> initialize() async {
    configuration.addConfigMap(initialConfig);
    // The command words and the command's own flags share the argument list
    // with the configuration options, so only the latter are taken here.
    configuration.applyArguments(arguments, strict: false);
    await super.initialize();
  }

  /// Runs [command] against every migration tool in the tree.
  Future<int> run(MigrationCommand command) async {
    if (!MigrationCommand.names.contains(command.name)) {
      stderr.writeln(
        'Unknown migration command "${command.name}". '
        'Expected one of: ${MigrationCommand.names.join(', ')}.',
      );
      return 64;
    }

    _command = command;

    try {
      await initialize();
    } catch (e) {
      stderr.writeln('Could not start the migration tool: $e');
      await _shutdownQuietly();
      return 1;
    }

    try {
      final tools = findAllComponents(const Find<SchemaMigrationTool>());
      if (tools.isEmpty) {
        stderr.writeln(
          'No migration tool found. Add a migration service (for example '
          'PostgresqlMigrationService) to the application components.',
        );
        return 1;
      }

      for (final tool in tools) {
        if (tools.length > 1) {
          stdout.writeln('[${tool.migrationToolName}]');
        }

        final int result;
        try {
          result = await tool.runMigrationCommand(command);
        } catch (e) {
          // A migration that is refused is an answer, not a crash: the reason
          // is what the person running this needs to read, not a stack trace.
          stderr.writeln(e);
          return 1;
        }

        if (result != 0) {
          return result;
        }
      }

      return 0;
    } finally {
      await _shutdownQuietly();
    }
  }

  Future<void> _shutdownQuietly() async {
    if (state == ServiceHostState.uninitialized) {
      return;
    }
    try {
      await shutdown();
    } catch (e) {
      stderr.writeln('Shutdown after the migration command failed: $e');
    }
  }
}
