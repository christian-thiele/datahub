import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';

abstract interface class ApertureTileSource() {
  Future<ApertureMapTiles?> resolve();
}

/// The public OpenStreetMap tile server.
///
/// Note that the OSM tile usage policy does not allow heavy use, consider
/// a different [ApertureTileSource] for production deployments.
class const OpenStreetMapTileSource() implements ApertureTileSource {
  @override
  Future<ApertureMapTiles?> resolve() async => ApertureMapTiles.openStreetMap;
}

/// Any tile server that serves `{z}/{x}/{y}` raster tiles.
class const CustomTileSource({
  final Config<String> urlTemplate = const Config('aperture.map.urlTemplate'),
  final Config<int?> maxZoom = const Config('aperture.map.maxZoom'),
  final Config<String?> attribution = const Config('aperture.map.attribution'),
}) implements ApertureTileSource {
  @override
  Future<ApertureMapTiles?> resolve() async => ApertureMapTiles(
    urlTemplate: urlTemplate.read(),
    maxZoom: maxZoom.read(),
    attribution: attribution.read(),
  );
}

/// Google Maps, served by the
/// [Map Tiles API](https://developers.google.com/maps/documentation/tile).
///
/// The tile session Google requires is created and renewed by the server. The
/// frontend receives a tile URL containing the session token and the API key,
/// so restrict the key to the Map Tiles API and to the origin Aperture is
/// served from.
class const GoogleMapsTileSource({
  final Config<String> apiKey = const Config('aperture.map.google.apiKey'),
  final Config<String> mapType = const Config(
    'aperture.map.google.mapType',
    defaultValue: 'satellite',
  ),
  final Config<String> language = const Config(
    'aperture.map.google.language',
    defaultValue: 'en-US',
  ),
  final Config<String> region = const Config(
    'aperture.map.google.region',
    defaultValue: 'US',
  ),
  final String endpoint = 'https://tile.googleapis.com',
}) implements ApertureTileSource {
  static const _renewMargin = Duration(hours: 1);

  static final _sessions = <String, _GoogleSession>{};
  static final _pending = <String, Future<_GoogleSession>>{};

  @override
  Future<ApertureMapTiles?> resolve() async {
    final key = apiKey.read();
    final type = mapType.read();
    final lang = language.read();
    final reg = region.read();

    final cacheKey = [endpoint, key, type, lang, reg].join('|');
    final cached = _sessions[cacheKey];
    final now = DateTime.now();

    if (cached == null || !cached.isValidAt(now.add(_renewMargin))) {
      try {
        final session = await (_pending[cacheKey] ??=
            _createSession(key, type, lang, reg).whenComplete(() {
              // Not an arrow function, the future removed here must not be awaited.
              _pending.remove(cacheKey);
            }));
        _sessions[cacheKey] = session;
        return _tilesOf(session, key);
      } catch (e) {
        log('Creating Google Maps tile session failed.\n$e');

        // The old session is still usable until it actually expires.
        if (cached != null && cached.isValidAt(now)) {
          return _tilesOf(cached, key);
        }

        return null;
      }
    }

    return _tilesOf(cached, key);
  }

  ApertureMapTiles _tilesOf(_GoogleSession session, String key) =>
      ApertureMapTiles(
        urlTemplate:
            '$endpoint/v1/2dtiles/{z}/{x}/{y}'
            '?session=${Uri.encodeQueryComponent(session.token)}'
            '&key=${Uri.encodeQueryComponent(key)}',
        maxZoom: 22,
        attribution: 'Map data © Google',
      );

  Future<_GoogleSession> _createSession(
    String key,
    String type,
    String lang,
    String reg,
  ) async {
    final client = await RestClient.connect(Uri.parse(endpoint));
    try {
      final response = await client
          .post(
            '/v1/createSession',
            {'mapType': type, 'language': lang, 'region': reg},
            query: {
              'key': [key],
            },
          )
          .thenGetJsonBody();

      final token = response['session'];
      final expiry = int.tryParse('${response['expiry']}');
      if (token is! String || expiry == null) {
        throw StateError('Unexpected createSession response.');
      }

      return _GoogleSession(
        token,
        DateTime.fromMillisecondsSinceEpoch(expiry * 1000),
      );
    } finally {
      await client.close();
    }
  }
}

class const _GoogleSession(final String token, final DateTime expiresAt) {
  bool isValidAt(DateTime time) => expiresAt.isAfter(time);
}
