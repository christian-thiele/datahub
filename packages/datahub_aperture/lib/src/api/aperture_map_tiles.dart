import 'package:datahub/data.dart';

part 'aperture_map_tiles.g.dart';

/// The raster tile server the map widgets of the Aperture frontend use.
///
/// Resolved by the Aperture server (see `ApertureTileSource`), so that
/// credentials, sessions and provider specifics never need to be configured
/// in the frontend.
@Data()
class ApertureMapTiles extends $ApertureMapTiles {
  static const openStreetMap = ApertureMapTiles(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    maxZoom: 19,
    attribution: '© OpenStreetMap contributors',
  );

  /// URL template with `{z}`, `{x}` and `{y}` placeholders.
  final String urlTemplate;

  /// The highest zoom level the server provides tiles for.
  final int? maxZoom;

  /// Attribution the provider requires to be displayed with the map.
  final String? attribution;

  const ApertureMapTiles({
    required this.urlTemplate,
    this.maxZoom,
    this.attribution,
  });
}
