import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:test/test.dart';

/// Reference encodings of the OGC well known binary format, little endian,
/// as PostGIS `ST_AsEWKB` produces them.
const _pointEwkb = '0101000020e6100000000000000000f03f0000000000000040';
const _lineStringWkb =
    '010200000002000000000000000000f03f00000000000000400000000000'
    '0008400000000000001040';
const _polygonWkb =
    '0103000000010000000400000000000000000000000000000000000000000000'
    '0000000000000000000000f03f000000000000f03f000000000000f03f000000'
    '0000000000'
    '0000000000000000';
const _multiPointWkb =
    '0104000000020000000101000000000000000000f03f000000000000004001'
    '0100000000000000000008400000000000001040';
const _multiLineStringWkb =
    '010500000001000000010200000002000000000000000000f03f0000000000'
    '00004000000000000008400000000000001040';
const _multiPolygonWkb =
    '0106000000010000000103000000010000000400000000000000000000000000'
    '0000000000000000000000000000000000000000f03f000000000000f03f0000'
    '00000000f03f'
    '0000000000000000'
    '0000000000000000';
const _collectionEwkb =
    '0107000020e6100000020000000101000000000000000000f03f000000000000'
    '0040010200000002000000000000000000f03f0000000000000040000000000000'
    '08400000000000001040';

/// A geometry with a Z value sets the high bit of the type word.
const _pointZWkb =
    '0101000080000000000000f03f0000000000000040000000000000'
    '0840';

Uint8List _bytes(String hex) => Uint8List.fromList([
  for (var i = 0; i < hex.length; i += 2)
    int.parse(hex.substring(i, i + 2), radix: 16),
]);

String _hex(Uint8List bytes) =>
    bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

Point _point(double x, double y) => Point(null, x, y);

final _line = LineString(null, [_point(1, 2), _point(3, 4)], false, false);

final _polygon = Polygon(
  null,
  [
    LineString(
      null,
      [_point(0, 0), _point(0, 1), _point(1, 1), _point(0, 0)],
      false,
      false,
    ),
  ],
  false,
  false,
);

void main() {
  group('parses the encoding of PostGIS', () {
    test('Point with an SRID', () {
      final point = Geometry.parseEWKB(_bytes(_pointEwkb)) as Point;

      expect(point.srid, wgs84);
      expect(point.x, 1);
      expect(point.y, 2);
    });

    test('LineString', () {
      final line = Geometry.parseEWKB(_bytes(_lineStringWkb)) as LineString;

      expect(line.points, hasLength(2));
      expect(line.points.last.y, 4);
    });

    test('Polygon', () {
      final polygon = Geometry.parseEWKB(_bytes(_polygonWkb)) as Polygon;

      expect(polygon.rings, hasLength(1));
      expect(polygon.rings.single.points, hasLength(4));
    });

    test('MultiPoint', () {
      final multi = Geometry.parseEWKB(_bytes(_multiPointWkb)) as MultiPoint;

      expect(multi.points.map((e) => e.x), [1, 3]);
      expect(multi.points.map((e) => e.y), [2, 4]);
    });

    test('MultiLineString', () {
      final multi =
          Geometry.parseEWKB(_bytes(_multiLineStringWkb)) as MultiLineString;

      expect(multi.lineStrings.single.points, hasLength(2));
    });

    test('MultiPolygon', () {
      final multi =
          Geometry.parseEWKB(_bytes(_multiPolygonWkb)) as MultiPolygon;

      expect(multi.polygons.single.rings.single.points, hasLength(4));
    });

    test('GeometryCollection of mixed members', () {
      final collection =
          Geometry.parseEWKB(_bytes(_collectionEwkb)) as GeometryCollection;

      expect(collection.srid, wgs84);
      expect(collection.geometry, hasLength(2));
      expect(collection.geometry.first, isA<Point>());
      expect(collection.geometry.last, isA<LineString>());
      expect((collection.geometry.last as LineString).points, hasLength(2));
    });

    test('Point with a Z value', () {
      final point = Geometry.parseEWKB(_bytes(_pointZWkb)) as Point;

      expect(point.hasZ, isTrue);
      expect(point.z, 3);
    });
  });

  group('writes the encoding of PostGIS', () {
    test('Point with an SRID', () {
      expect(_hex(Point(wgs84, 1, 2).toEWKB()), _pointEwkb);
    });

    test('LineString', () {
      expect(_hex(_line.toEWKB()), _lineStringWkb);
    });

    test('Polygon', () {
      expect(_hex(_polygon.toEWKB()), _polygonWkb);
    });

    test('MultiPoint', () {
      final multi = MultiPoint(
        null,
        [_point(1, 2), _point(3, 4)],
        false,
        false,
      );

      expect(_hex(multi.toEWKB()), _multiPointWkb);
    });

    test('MultiLineString', () {
      final multi = MultiLineString(null, [_line], false, false);

      expect(_hex(multi.toEWKB()), _multiLineStringWkb);
    });

    test('MultiPolygon', () {
      final multi = MultiPolygon(null, [_polygon], false, false);

      expect(_hex(multi.toEWKB()), _multiPolygonWkb);
    });

    test('GeometryCollection of mixed members', () {
      final collection = GeometryCollection(
        wgs84,
        [_point(1, 2), _line],
        false,
        false,
      );

      expect(_hex(collection.toEWKB()), _collectionEwkb);
    });

    test('Point with a Z value', () {
      expect(_hex(Point(null, 1, 2, 3).toEWKB()), _pointZWkb);
    });
  });

  group('round trips', () {
    final geometries = <String, Geometry>{
      'Point': Point(wgs84, 1, 2),
      'Point ZM': Point(wgs84, 1, 2, 3, 4),
      'LineString': LineString(
        wgs84,
        [Point(wgs84, 1, 2), Point(wgs84, 3, 4)],
        false,
        false,
      ),
      'Polygon with a hole': Polygon(
        wgs84,
        [
          LineString(
            wgs84,
            [
              Point(wgs84, 0, 0),
              Point(wgs84, 0, 10),
              Point(wgs84, 10, 10),
              Point(wgs84, 0, 0),
            ],
            false,
            false,
          ),
          LineString(
            wgs84,
            [
              Point(wgs84, 1, 1),
              Point(wgs84, 1, 2),
              Point(wgs84, 2, 2),
              Point(wgs84, 1, 1),
            ],
            false,
            false,
          ),
        ],
        false,
        false,
      ),
      'MultiPoint': MultiPoint(
        wgs84,
        [Point(wgs84, 1, 2), Point(wgs84, 3, 4)],
        false,
        false,
      ),
      'MultiLineString': MultiLineString(
        wgs84,
        [
          LineString(
            wgs84,
            [Point(wgs84, 1, 2), Point(wgs84, 3, 4)],
            false,
            false,
          ),
        ],
        false,
        false,
      ),
      'MultiPolygon': MultiPolygon(
        wgs84,
        [
          Polygon(
            wgs84,
            [
              LineString(
                wgs84,
                [
                  Point(wgs84, 0, 0),
                  Point(wgs84, 0, 1),
                  Point(wgs84, 1, 1),
                  Point(wgs84, 0, 0),
                ],
                false,
                false,
              ),
            ],
            false,
            false,
          ),
        ],
        false,
        false,
      ),
    };

    for (final entry in geometries.entries) {
      test(entry.key, () {
        expect(Geometry.parseEWKB(entry.value.toEWKB()), entry.value);
      });
    }

    test('GeometryCollection of every member type', () {
      final collection = GeometryCollection(
        wgs84,
        geometries.values.toList(),
        false,
        false,
      );

      expect(Geometry.parseEWKB(collection.toEWKB()), collection);
    });

    test('a GeometryCollection sent through the json codec', () {
      const codec = JsonDataCodec();
      final collection = GeometryCollection(
        wgs84,
        geometries.values.toList(),
        false,
        false,
      );

      expect(
        codec.decodeGeometry(codec.encodeGeometry(collection)),
        collection,
      );
    });

    test('nested GeometryCollection', () {
      final collection = GeometryCollection(
        wgs84,
        [
          Point(wgs84, 1, 2),
          GeometryCollection(wgs84, [Point(wgs84, 3, 4)], false, false),
        ],
        false,
        false,
      );

      expect(Geometry.parseEWKB(collection.toEWKB()), collection);
    });

    test('big endian', () {
      final collection = GeometryCollection(
        wgs84,
        [
          Point(wgs84, 1, 2),
          LineString(
            wgs84,
            [Point(wgs84, 1, 2), Point(wgs84, 3, 4)],
            false,
            false,
          ),
        ],
        false,
        false,
      );

      expect(
        Geometry.parseEWKB(collection.toEWKB(byteOrder: ByteOrder.wkbXDR)),
        collection,
      );
    });
  });
}
