import 'service_host.dart';
import 'application_host.dart';

Future<void> runApp(List<Component> components) async {
  final host = ApplicationHost(components: components);
  await host.run();
}
