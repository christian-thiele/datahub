import 'service_host.dart';
import 'application_host.dart';

Future<void> runApp(
  List<Component> components, {
  List<String> arguments = const [],
  Map<String, dynamic> config = const {},
}) async {
  final host = ApplicationHost(
    components: components,
    arguments: arguments,
    initialConfig: config,
  );
  await host.run();
}
