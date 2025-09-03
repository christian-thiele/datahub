import 'package:datahub/api.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/src/api/aperture_bootstrap.dart';

class BootstrapEndpoint extends ApiEndpoint {
  final ApertureConfigDelegate config;

  BootstrapEndpoint({required this.config})
      : super(RoutePattern('/api/bootstrap'));

  @override
  Future<ApertureBootstrap> get(ApiRequest request) async {
    return ApertureBootstrap(title: 'Aperture', theme: config.theme);
  }
}
