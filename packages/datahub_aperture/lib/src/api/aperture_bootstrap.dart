import 'package:datahub/datahub.dart';

import 'aperture_map_tiles.dart';
import 'aperture_theme.dart';

part 'aperture_bootstrap.g.dart';

@Data()
class ApertureBootstrap extends $ApertureBootstrap {
  final String title;

  final ApertureTheme theme;
  final Environment environment;

  /// The tile server for maps, `null` if maps should be shown without tiles.
  final ApertureMapTiles? mapTiles;

  final String oidcIssuer;
  final List<String> oidcScopes;
  final String? oidcClientId;
  final String? oidcClientSecret;

  const ApertureBootstrap({
    required this.title,
    required this.theme,
    required this.environment,
    required this.mapTiles,
    required this.oidcIssuer,
    required this.oidcScopes,
    required this.oidcClientId,
    required this.oidcClientSecret,
  });
}
