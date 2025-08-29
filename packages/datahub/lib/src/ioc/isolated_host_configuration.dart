import 'package:datahub/services.dart';

class IsolatedHostConfiguration {
  final Map<String, dynamic> config;
  final LogBackend logBackend;

  IsolatedHostConfiguration(
    this.config,
    this.logBackend,
  );
}
