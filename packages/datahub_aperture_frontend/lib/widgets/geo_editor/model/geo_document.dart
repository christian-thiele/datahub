import 'package:boost/boost.dart';
import 'package:datahub/data.dart' as data;
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart';

import 'geo_feature.dart';
import 'geo_type_restriction.dart';

/// The value of the geo editor as a flat list of editable features.
///
/// Multi geometries and geometry collections are flattened into features on
/// read and re-assembled into the narrowest geometry type a
/// [GeoTypeRestriction] permits on write.
@immutable
class GeoDocument {
  final List<GeoFeature> features;

  /// The spatial reference of the edited value, kept as it was read so that
  /// writing back does not change it.
  final int? srid;

  /// Whether the edited value carries Z / M values. New vertices are written
  /// with a zero value for those, existing vertices keep theirs.
  final bool hasZ;
  final bool hasM;

  GeoDocument(
    Iterable<GeoFeature> features, {
    this.srid = data.wgs84,
    this.hasZ = false,
    this.hasM = false,
  }) : features = List.unmodifiable(features);

  factory GeoDocument.fromGeometry(data.Geometry? geometry) =>
      switch (geometry) {
        null => GeoDocument(const []),
        final geometry => GeoDocument(
          _flatten(geometry),
          srid: geometry.srid ?? data.wgs84,
          hasZ: geometry.hasZ,
          hasM: geometry.hasM,
        ),
      };

  GeoDocument copyWith({Iterable<GeoFeature>? features}) => GeoDocument(
    features ?? this.features,
    srid: srid,
    hasZ: hasZ,
    hasM: hasM,
  );

  bool get isEmpty => features.isEmpty;

  bool get isNotEmpty => features.isNotEmpty;

  Set<GeoFeatureKind> get kinds => features.map((e) => e.kind).toSet();

  Iterable<LatLng> get positions => features.expand((e) => e.positions);

  LatLngBounds? get bounds {
    final points = positions.toList();
    return points.isEmpty ? null : LatLngBounds.fromPoints(points);
  }

  GeoFeature? featureAt(int? index) =>
      index != null && index >= 0 && index < features.length
      ? features[index]
      : null;

  /// The narrowest geometry type [restriction] allows for the current
  /// features, `null` if there is nothing to write.
  ///
  /// Features of mixed kinds and features that cannot be expressed within the
  /// restriction fall back to their natural representation, which the backend
  /// rejects with a validation error instead of the editor silently discarding
  /// what was drawn.
  data.GeometryType? resolveType(GeoTypeRestriction restriction) {
    if (features.isEmpty) {
      return null;
    }

    final kinds = this.kinds;
    if (kinds.length > 1) {
      return data.GeometryType.geometryCollection;
    }

    final kind = kinds.single;
    if (features.length == 1 && restriction.allows(kind.singleType)) {
      return kind.singleType;
    }

    if (restriction.allows(kind.multiType)) {
      return kind.multiType;
    }

    if (restriction.allowsCollection) {
      return data.GeometryType.geometryCollection;
    }

    return features.length == 1 ? kind.singleType : kind.multiType;
  }

  /// Assembles the features into a geometry of [resolveType].
  data.Geometry? toGeometry(GeoTypeRestriction restriction) =>
      switch (resolveType(restriction)) {
        null => null,
        data.GeometryType.point ||
        data.GeometryType.lineString ||
        data.GeometryType.polygon => _single(features.single),
        data.GeometryType.multiPoint ||
        data.GeometryType.multiLineString ||
        data.GeometryType.multiPolygon => _multi(kinds.single, features),
        data.GeometryType.geometryCollection => _collection(features),
      };

  /// Describes what would be stored, e.g. `MultiPolygon · 12 vertices`.
  String describe(GeoTypeRestriction restriction) {
    final type = resolveType(restriction);
    if (type == null) {
      return 'No geometry';
    }

    final vertices = features.fold<int>(0, (sum, e) => sum + e.vertexCount);
    return '${type.displayName} · $vertices '
        '${vertices == 1 ? 'vertex' : 'vertices'}';
  }

  data.Geometry _single(GeoFeature feature) =>
      feature.toGeometry(srid, hasZ: hasZ, hasM: hasM);

  data.Geometry _multi(GeoFeatureKind kind, List<GeoFeature> features) =>
      switch (kind) {
        GeoFeatureKind.point => data.MultiPoint(
          srid,
          [
            for (final feature in features.whereType<GeoPointFeature>())
              feature.toGeometry(srid, hasZ: hasZ, hasM: hasM),
          ],
          hasZ,
          hasM,
        ),
        GeoFeatureKind.line => data.MultiLineString(
          srid,
          [
            for (final feature in features.whereType<GeoLineFeature>())
              feature.toGeometry(srid, hasZ: hasZ, hasM: hasM),
          ],
          hasZ,
          hasM,
        ),
        GeoFeatureKind.polygon => data.MultiPolygon(
          srid,
          [
            for (final feature in features.whereType<GeoPolygonFeature>())
              feature.toGeometry(srid, hasZ: hasZ, hasM: hasM),
          ],
          hasZ,
          hasM,
        ),
      };

  data.Geometry _collection(List<GeoFeature> features) =>
      data.GeometryCollection(
        srid,
        [for (final feature in features) _single(feature)],
        hasZ,
        hasM,
      );

  static Iterable<GeoFeature> _flatten(data.Geometry geometry) sync* {
    switch (geometry) {
      case data.GeometryCollection collection:
        for (final child in collection.geometry) {
          yield* _flatten(child);
        }
      case data.MultiPoint multiPoint:
        for (final point in multiPoint.points) {
          yield GeoPointFeature(GeoVertex.fromPoint(point));
        }
      case data.MultiLineString multiLineString:
        for (final lineString in multiLineString.lineStrings) {
          final feature = _lineOf(lineString);
          if (feature != null) {
            yield feature;
          }
        }
      case data.MultiPolygon multiPolygon:
        for (final polygon in multiPolygon.polygons) {
          final feature = _polygonOf(polygon);
          if (feature != null) {
            yield feature;
          }
        }
      case data.Point point:
        yield GeoPointFeature(GeoVertex.fromPoint(point));
      case data.LineString lineString:
        final feature = _lineOf(lineString);
        if (feature != null) {
          yield feature;
        }
      case data.Polygon polygon:
        final feature = _polygonOf(polygon);
        if (feature != null) {
          yield feature;
        }
    }
  }

  static GeoLineFeature? _lineOf(data.LineString lineString) {
    final points = lineString.points.map(GeoVertex.fromPoint).toList();
    return points.length >= 2 ? GeoLineFeature(points) : null;
  }

  static GeoPolygonFeature? _polygonOf(data.Polygon polygon) {
    final rings = polygon.rings
        .map((ring) => _unclose(ring.points.map(GeoVertex.fromPoint).toList()))
        .where((ring) => ring.length >= 3)
        .toList();

    return rings.isEmpty ? null : GeoPolygonFeature(rings);
  }

  /// Drops the repeated closing vertex rings are stored with in WKB.
  static List<GeoVertex> _unclose(List<GeoVertex> ring) =>
      ring.length > 1 && ring.first.position == ring.last.position
      ? ring.sublist(0, ring.length - 1)
      : ring;

  @override
  bool operator ==(Object other) =>
      other is GeoDocument &&
      other.srid == srid &&
      other.hasZ == hasZ &&
      other.hasM == hasM &&
      other.features.sequenceEquals(features);

  @override
  int get hashCode => Object.hash(srid, hasZ, hasM, Object.hashAll(features));
}
