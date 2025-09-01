import 'package:datahub_aperture/src/aperture_service/aperture_resource.dart';

abstract interface class ApertureConfigDelegate {
  List<ApertureResource> get resources;
}

class ApertureConfigStaticDelegate implements ApertureConfigDelegate {
  @override
  final List<ApertureResource> resources;

  ApertureConfigStaticDelegate({this.resources = const []});
}
