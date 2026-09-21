import 'dart:convert';
import 'dart:io' as io;

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/services.dart';
import 'package:test/test.dart';

/// Stands in for the Google Map Tiles API and records the requests it gets.
class _FakeGoogle {
  final io.HttpServer server;
  final requests = <Uri>[];
  final bodies = <Map<String, dynamic>>[];
  int status = 200;
  int sessionCounter = 0;
  DateTime expiry = DateTime.now().add(const Duration(days: 14));

  _FakeGoogle._(this.server) {
    server.listen((request) async {
      requests.add(request.uri);
      bodies.add(
        jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, dynamic>,
      );
      request.response.statusCode = status;
      request.response.headers.contentType = io.ContentType.json;
      request.response.write(
        jsonEncode({
          'session': 'session-${++sessionCounter}',
          'expiry': '${expiry.millisecondsSinceEpoch ~/ 1000}',
        }),
      );
      await request.response.close();
    });
  }

  static Future<_FakeGoogle> start() async => _FakeGoogle._(
    await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0),
  );

  String get endpoint => 'http://127.0.0.1:${server.port}';

  Future<void> close() => server.close(force: true);
}

GoogleMapsTileSource _source(_FakeGoogle google, {String key = 'test-key'}) =>
    GoogleMapsTileSource(
      apiKey: Config.value(key),
      mapType: const Config.value('satellite'),
      language: const Config.value('de-DE'),
      region: const Config.value('DE'),
      endpoint: google.endpoint,
    );

void main() {
  declareTest('OpenStreetMapTileSource resolves the OSM server', [], () async {
    final tiles = await const OpenStreetMapTileSource().resolve();

    expect(
      tiles?.urlTemplate,
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
    expect(tiles?.attribution, isNotNull);
  });

  declareTest('CustomTileSource resolves the configured server', [], () async {
    final tiles = await const CustomTileSource(
      urlTemplate: Config.value('https://tiles.example.com/{z}/{x}/{y}.png'),
      maxZoom: Config.value(12),
      attribution: Config.value(null),
    ).resolve();

    expect(tiles?.urlTemplate, 'https://tiles.example.com/{z}/{x}/{y}.png');
    expect(tiles?.maxZoom, 12);
    expect(tiles?.attribution, isNull);
  });

  declareTest('GoogleMapsTileSource creates a session', [], () async {
    final google = await _FakeGoogle.start();
    addTearDown(google.close);

    final tiles = await _source(google, key: 'key-create').resolve();

    expect(google.requests.single.path, '/v1/createSession');
    expect(google.requests.single.queryParameters, {'key': 'key-create'});
    expect(google.bodies.single, {
      'mapType': 'satellite',
      'language': 'de-DE',
      'region': 'DE',
    });
    expect(
      tiles?.urlTemplate,
      '${google.endpoint}/v1/2dtiles/{z}/{x}/{y}'
      '?session=session-1&key=key-create',
    );
    expect(tiles?.attribution, contains('Google'));
  });

  declareTest('GoogleMapsTileSource reuses the session', [], () async {
    final google = await _FakeGoogle.start();
    addTearDown(google.close);
    final source = _source(google, key: 'key-reuse');

    final first = await source.resolve();
    final second = await source.resolve();

    expect(google.requests, hasLength(1));
    expect(second?.urlTemplate, first?.urlTemplate);
  });

  declareTest(
    'GoogleMapsTileSource renews a session close to expiry',
    [],
    () async {
      final google = await _FakeGoogle.start();
      addTearDown(google.close);
      google.expiry = DateTime.now().add(const Duration(minutes: 10));
      final source = _source(google, key: 'key-renew');

      await source.resolve();
      final renewed = await source.resolve();

      expect(google.requests, hasLength(2));
      expect(renewed?.urlTemplate, contains('session=session-2'));
    },
  );

  declareTest(
    'GoogleMapsTileSource keeps a valid session when renewing fails',
    [],
    () async {
      final google = await _FakeGoogle.start();
      addTearDown(google.close);
      google.expiry = DateTime.now().add(const Duration(minutes: 10));
      final source = _source(google, key: 'key-fallback');

      await source.resolve();
      google.status = 403;
      final tiles = await source.resolve();

      expect(tiles?.urlTemplate, contains('session=session-1'));
    },
  );

  declareTest(
    'GoogleMapsTileSource resolves no tiles if the session fails',
    [],
    () async {
      final google = await _FakeGoogle.start();
      addTearDown(google.close);
      google.status = 403;

      expect(await _source(google, key: 'key-fail').resolve(), isNull);
    },
  );
}
