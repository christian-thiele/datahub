part of 'geo_editor_cubit.dart';

class GeoPolygon {
  final List<List<LatLng>> rings;

  GeoPolygon(List<List<LatLng>> rings)
    : rings = List.unmodifiable(rings.map((e) => List<LatLng>.unmodifiable(e)));

  GeoPolygon.withBounds(List<LatLng> bounds) : this([bounds]);

  GeoPolygon addRing(List<LatLng> ring) => GeoPolygon([...rings, ring]);

  GeoPolygon replaceRing(int index, List<LatLng> ring) =>
      GeoPolygon(rings.copyWithReplaced(index, ring));

  GeoPolygon removeRing(int index) => GeoPolygon(rings.copyWithRemoved(index));

  static bool _isPointInside(List<List<LatLng>> rings, LatLng point) {
    final pt = convertToWebMercator(point.longitude, point.latitude);
    final coords = <List<List<double>>>[];
    for (final ring in rings) {
      final transformedRing = <List<double>>[];

      for (final point in ring) {
        final List<double> transformedPoint = convertToWebMercator(
          point.longitude,
          point.latitude,
        );
        transformedRing.add(transformedPoint);
      }

      coords.add(transformedRing);
    }
    var outer = coords.first;
    bool inside = false;
    for (int i = 0, j = outer.length - 1; i < outer.length; j = i++) {
      if (((outer[i][1] > pt[1]) != (outer[j][1] > pt[1])) &&
          (pt[0] <
              (outer[j][0] - outer[i][0]) *
                      (pt[1] - outer[i][1]) /
                      (outer[j][1] - outer[i][1]) +
                  outer[i][0])) {
        inside = !inside;
      }
    }
    return inside;
  }

  bool isPointInside(LatLng point) {
    if (rings.first.isNotEmpty &&
        LatLngBounds.fromPoints(rings.first).contains(point)) {
      return _isPointInside([rings.first], point);
    }

    return false;
  }

  data.Polygon toGeometry() {
    return data.Polygon(
      data.wgs84,
      [
        for (final ring in rings)
          data.LineString(
            data.wgs84,
            [
              for (final point in ring.followedBy([ring.first]))
                data.Point(data.wgs84, point.longitude, point.latitude),
            ],
            false,
            false,
          ),
      ],
      false,
      false,
    );
  }
}

sealed class GeoEditorState {
  final List<GeoPolygon> polygons;

  GeoEditorState({required this.polygons});
}

class GeoEditorStateIdle extends GeoEditorState {
  GeoEditorStateIdle({required super.polygons});
}

class GeoEditorStateCreatePolygon extends GeoEditorState {
  final GeoPolygon creating;
  final int ringIndex;

  GeoEditorStateCreatePolygon({
    required super.polygons,
    required this.creating,
    required this.ringIndex,
  });
}

class GeoEditorStateEditPolygon extends GeoEditorState {
  final int polygonIndex;
  final int ringIndex;
  final int vertexIndex;

  GeoEditorStateEditPolygon({
    required super.polygons,
    required this.polygonIndex,
    required this.ringIndex,
    required this.vertexIndex,
  });
}
