import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_document.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_feature.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

const _any = GeoTypeRestriction.any();

data.Point _point(double lat, double lng, {double? z, double? m}) =>
    data.Point(data.wgs84, lng, lat, z, m);

data.LineString _ring(List<(double, double)> points) => data.LineString(
  data.wgs84,
  [
    for (final (lat, lng) in points) _point(lat, lng),
    _point(points.first.$1, points.first.$2),
  ],
  false,
  false,
);

final _triangle = data.Polygon(
  data.wgs84,
  [
    _ring([(0, 0), (0, 1), (1, 1)]),
  ],
  false,
  false,
);

void main() {
  group('reading a geometry', () {
    test('flattens a multi geometry into one feature per member', () {
      final document = GeoDocument.fromGeometry(
        data.MultiPoint(data.wgs84, [_point(1, 2), _point(3, 4)], false, false),
      );

      expect(document.features, hasLength(2));
      expect(document.kinds, {GeoFeatureKind.point});
      expect(
        document.positions,
        containsAllInOrder([LatLng(1, 2), LatLng(3, 4)]),
      );
    });

    test('flattens nested geometry collections', () {
      final document = GeoDocument.fromGeometry(
        data.GeometryCollection(
          data.wgs84,
          [
            _point(1, 2),
            data.GeometryCollection(data.wgs84, [_triangle], false, false),
          ],
          false,
          false,
        ),
      );

      expect(document.features.map((e) => e.kind), [
        GeoFeatureKind.point,
        GeoFeatureKind.polygon,
      ]);
    });

    test('drops the repeated closing vertex of polygon rings', () {
      final document = GeoDocument.fromGeometry(_triangle);
      final feature = document.features.single as GeoPolygonFeature;

      expect(feature.outerRing, hasLength(3));
      expect(feature.holes, isEmpty);
    });

    test('keeps holes as additional parts', () {
      final polygon = data.Polygon(
        data.wgs84,
        [
          _ring([(0, 0), (0, 10), (10, 10), (10, 0)]),
          _ring([(2, 2), (2, 4), (4, 4)]),
        ],
        false,
        false,
      );

      final feature =
          GeoDocument.fromGeometry(polygon).features.single
              as GeoPolygonFeature;

      expect(feature.parts, hasLength(2));
      expect(feature.holes.single, hasLength(3));
    });

    test('skips degenerate rings and lines', () {
      final document = GeoDocument.fromGeometry(
        data.GeometryCollection(
          data.wgs84,
          [
            data.LineString(data.wgs84, [_point(1, 1)], false, false),
            _point(2, 2),
          ],
          false,
          false,
        ),
      );

      expect(document.features, hasLength(1));
      expect(document.features.single, isA<GeoPointFeature>());
    });

    test('is empty for a null value', () {
      expect(GeoDocument.fromGeometry(null).features, isEmpty);
    });
  });

  group('writing a geometry', () {
    test('is null while there is nothing to write', () {
      expect(GeoDocument(const []).toGeometry(_any), isNull);
    });

    test('round trips a polygon with a hole', () {
      final polygon = data.Polygon(
        data.wgs84,
        [
          _ring([(0, 0), (0, 10), (10, 10), (10, 0)]),
          _ring([(2, 2), (2, 4), (4, 4)]),
        ],
        false,
        false,
      );

      expect(GeoDocument.fromGeometry(polygon).toGeometry(_any), polygon);
    });

    test('round trips a geometry collection', () {
      final collection = data.GeometryCollection(
        data.wgs84,
        [_point(1, 2), _triangle],
        false,
        false,
      );

      expect(GeoDocument.fromGeometry(collection).toGeometry(_any), collection);
    });

    test('keeps the srid of the value it was read from', () {
      final point = data.Point(3857, 2, 1);
      final written = GeoDocument.fromGeometry(point).toGeometry(_any);

      expect(written, isA<data.Point>());
      expect(written!.srid, 3857);
    });

    test('keeps z and m values of untouched vertices', () {
      final point = _point(1, 2, z: 30, m: 40);
      final document = GeoDocument.fromGeometry(point);

      expect(document.hasZ, isTrue);
      expect(document.hasM, isTrue);
      expect(document.toGeometry(_any), point);
    });

    test('writes new vertices of a 3D geometry with a zero z', () {
      final document = GeoDocument.fromGeometry(_point(1, 2, z: 30));
      final moved = document.copyWith(
        features: [...document.features, GeoPointFeature.at(LatLng(3, 4))],
      );

      final written = moved.toGeometry(_any) as data.MultiPoint;
      expect(written.hasZ, isTrue);
      expect(written.points.last.z, 0);
    });
  });

  group('type restriction', () {
    final points = [
      GeoPointFeature.at(LatLng(1, 1)),
      GeoPointFeature.at(LatLng(2, 2)),
    ];

    test('writes a single feature as its plain type', () {
      final document = GeoDocument([points.first]);
      expect(document.toGeometry(_any), isA<data.Point>());
    });

    test('writes several features of one kind as a multi geometry', () {
      expect(GeoDocument(points).toGeometry(_any), isA<data.MultiPoint>());
    });

    test('writes mixed kinds as a geometry collection', () {
      final document = GeoDocument([
        points.first,
        GeoLineFeature([GeoVertex(LatLng(0, 0)), GeoVertex(LatLng(1, 1))]),
      ]);

      expect(document.toGeometry(_any), isA<data.GeometryCollection>());
    });

    test('widens a single feature when only the multi type is allowed', () {
      final restriction = GeoTypeRestriction.only(data.GeometryType.multiPoint);

      expect(
        GeoDocument([points.first]).toGeometry(restriction),
        isA<data.MultiPoint>(),
      );
    });

    test('falls back to a collection when the multi type is not allowed', () {
      final restriction = GeoTypeRestriction([
        data.GeometryType.point,
        data.GeometryType.geometryCollection,
      ]);

      expect(
        GeoDocument(points).toGeometry(restriction),
        isA<data.GeometryCollection>(),
      );
    });

    test('only offers the kinds it allows', () {
      final restriction = GeoTypeRestriction([data.GeometryType.multiPolygon]);

      expect(restriction.kinds, [GeoFeatureKind.polygon]);
      expect(restriction.allowsKind(GeoFeatureKind.point), isFalse);
      expect(restriction.allowsMultiple(GeoFeatureKind.polygon), isTrue);
    });

    test('allows a second feature only where the type can hold one', () {
      final single = GeoTypeRestriction.only(data.GeometryType.point);

      expect(single.canAdd(GeoFeatureKind.point, const []), isTrue);
      expect(single.canAdd(GeoFeatureKind.point, [points.first]), isFalse);
      expect(single.canAdd(GeoFeatureKind.line, const []), isFalse);
    });

    test('allows mixing kinds only in a collection', () {
      final multi = GeoTypeRestriction([
        data.GeometryType.multiPoint,
        data.GeometryType.multiLineString,
      ]);

      expect(multi.canAdd(GeoFeatureKind.line, points), isFalse);
      expect(
        const GeoTypeRestriction.any().canAdd(GeoFeatureKind.line, points),
        isTrue,
      );
    });
  });

  group('editing features', () {
    final polygon = GeoPolygonFeature([
      [
        GeoVertex(LatLng(0, 0)),
        GeoVertex(LatLng(0, 1)),
        GeoVertex(LatLng(1, 1)),
        GeoVertex(LatLng(1, 0)),
      ],
    ]);

    test('inserting a vertex splits the addressed segment', () {
      final updated = polygon.insertVertex(
        const GeoVertexRef(0, 0, 2),
        LatLng(5, 5),
      );

      expect(updated!.parts.single.map((e) => e.position), [
        LatLng(0, 0),
        LatLng(0, 1),
        LatLng(5, 5),
        LatLng(1, 1),
        LatLng(1, 0),
      ]);
    });

    test('moving a vertex keeps its z value', () {
      final line = GeoLineFeature([
        GeoVertex(LatLng(0, 0), z: 7),
        GeoVertex(LatLng(1, 1)),
      ]);

      final moved =
          line.moveVertex(const GeoVertexRef(0, 0, 0), LatLng(2, 2))
              as GeoLineFeature;

      expect(moved.points.first.position, LatLng(2, 2));
      expect(moved.points.first.z, 7);
    });

    test('removing a vertex below the minimum drops the feature', () {
      final triangle = GeoPolygonFeature([polygon.outerRing.take(3).toList()]);

      expect(triangle.removeVertex(const GeoVertexRef(0, 0, 0)), isNull);
    });

    test('removing a hole vertex below the minimum drops only the hole', () {
      final withHole = polygon.addPart([
        GeoVertex(LatLng(0.2, 0.2)),
        GeoVertex(LatLng(0.2, 0.4)),
        GeoVertex(LatLng(0.4, 0.4)),
      ])!;

      final updated = withHole.removeVertex(const GeoVertexRef(0, 1, 0));

      expect(updated, isNotNull);
      expect(updated!.parts, hasLength(1));
    });

    test('describes what would be stored', () {
      expect(GeoDocument([polygon]).describe(_any), 'Polygon · 4 vertices');
      expect(GeoDocument(const []).describe(_any), 'No geometry');
    });
  });
}
