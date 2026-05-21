import 'package:datahub_aperture/api.dart';
import 'aperture_action.dart';
import 'aperture_module.dart';
import 'aperture_resource.dart';

abstract interface class ApertureConfigDelegate {
  String get title;
  ApertureTheme get theme;
  List<ApertureResource> get resources;
  List<ApertureAction> get actions;
  List<ApertureModule> get modules;
}

class ApertureConfigStaticDelegate implements ApertureConfigDelegate {
  @override
  final String title;

  @override
  final ApertureTheme theme;

  @override
  final List<ApertureResource> resources;

  @override
  final List<ApertureAction> actions;

  @override
  final List<ApertureModule> modules;


  ApertureConfigStaticDelegate({
    this.title = 'Aperture',
    this.theme = const ApertureTheme(),
    this.resources = const [],
    this.actions = const [],
    this.modules = const [],
  });

}
