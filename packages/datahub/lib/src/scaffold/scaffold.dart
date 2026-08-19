import 'dart:io';

import 'application_host.dart';
import 'migration/schema_migration_tool.dart';
import 'migration_host.dart';
import 'service_host.dart';

/// Starts the application described by [components].
///
/// When [arguments] begin with `migrate` the component tree is built for the
/// migration CLI instead of being started - see [MigrationHost]. That is what
/// lets `datahub migrate` work with the application's own data model without
/// the application having to expose it anywhere.
Future<void> runApp(
  List<Component> components, {
  List<String> arguments = const [],
  Map<String, dynamic> config = const {},
}) async {
  if (MigrationCommand.tryParse(arguments) case final command?) {
    final host = MigrationHost(
      components: components,
      arguments: arguments,
      initialConfig: config,
    );
    // A tool has to terminate. Services that were started for it may hold
    // timers - a connection pool keeps one - which would otherwise keep the
    // isolate alive long after the command is done.
    exit(await host.run(command));
  }

  final host = ApplicationHost(
    components: components,
    arguments: arguments,
    initialConfig: config,
  );
  await host.run();
}
