import 'package:datahub_aperture/api.dart';
import 'aperture_resource.dart';

abstract interface class ApertureConfigDelegate {
  String get title;
  ApertureTheme get theme;
  List<ApertureResource> get resources;
  String get baseUrl;
}

class ApertureConfigStaticDelegate implements ApertureConfigDelegate {
  @override
  final String title;

  @override
  final ApertureTheme theme;

  @override
  final List<ApertureResource> resources;

  @override
  final String baseUrl;

  ApertureConfigStaticDelegate({
    this.title = 'Aperture',
    this.theme = const ApertureTheme(),
    this.resources = const [],
    required this.baseUrl,
  });
}
