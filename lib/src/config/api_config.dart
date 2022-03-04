import 'package:cl_datahub/cl_datahub.dart';

/// Interface for config models that implement API startup configuration.
///
/// Usually consumed by [ApiService].
abstract class ApiConfig {
  dynamic get address;
  int get port;
}
