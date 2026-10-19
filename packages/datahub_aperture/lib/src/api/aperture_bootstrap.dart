import 'package:datahub/datahub.dart';

import 'aperture_map_tiles.dart';
import 'aperture_theme.dart';

part 'aperture_bootstrap.g.dart';

@Data()
class const ApertureBootstrap({
  required final String version,
  required final String title,
  required final ApertureTheme theme,
  required final Environment environment,

  /// The tile server for maps, `null` if maps should be shown without tiles.
  required final ApertureMapTiles? mapTiles,
  required final String oidcIssuer,
  required final List<String> oidcScopes,
  required final String? oidcClientId,
  required final String? oidcClientSecret,
}) extends $ApertureBootstrap;
