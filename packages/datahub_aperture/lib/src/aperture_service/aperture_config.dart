import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';

import 'aperture_resource.dart';

abstract interface class ApertureConfigDelegate {
  String get title;
  ApertureTheme get theme;
  List<ApertureResource> get resources;
}

class ApertureConfigStaticDelegate implements ApertureConfigDelegate {
  @override
  final String title;

  @override
  final ApertureTheme theme;

  @override
  final List<ApertureResource> resources;

  ApertureConfigStaticDelegate({
    this.title = 'Aperture',
    this.theme = const ApertureTheme(),
    this.resources = const [],
  });
}
