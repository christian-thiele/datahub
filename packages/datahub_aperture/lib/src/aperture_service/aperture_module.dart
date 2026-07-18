import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';

abstract interface class ApertureModule {
  ModuleDescription get description;

  List<ApiRoute> buildApiRoutes(String base);
}
