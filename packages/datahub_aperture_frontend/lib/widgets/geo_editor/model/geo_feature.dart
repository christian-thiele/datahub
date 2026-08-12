import 'package:boost/boost.dart';
import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// The kinds of shape the editor knows how to draw.
///
/// A feature is serialized as [singleType] when it is the only feature of the
/// edited value and as part of a [multiType] when it shares the value with
/// features of the same kind.
enum GeoFeatureKind {
  point(data.GeometryType.point, data.GeometryType.multiPoint),
  line(data.GeometryType.lineString, data.GeometryType.multiLineString),
  polygon(data.GeometryType.polygon, data.GeometryType.multiPolygon);

  const GeoFeatureKind(this.singleType, this.multiType);

  final data.GeometryType singleType;
  final data.GeometryType multiType;

  /// The kind a geometry of [type] is edited as, `null` for
  /// [data.GeometryType.geometryCollection] which has no kind of its own.
  static GeoFeatureKind? ofType(data.GeometryType type) => GeoFeatureKind.values
      .where((e) => e.singleType == type || e.multiType == type)
      .firstOrNull;
}

extension GeometryTypeName on data.GeometryType {
  String get displayName => switch (this) {
    data.GeometryType.point => 'Point',
    data.GeometryType.lineString => 'LineString',
    data.GeometryType.polygon => 'Polygon',
    data.GeometryType.multiPoint => 'MultiPoint',
    data.GeometryType.multiLineString => 'MultiLineString',
    data.GeometryType.multiPolygon => 'MultiPolygon',
    data.GeometryType.geometryCollection => 'GeometryCollection',
  };
}

/// A single editable position.
///
/// Z and M values of the geometry a vertex was read from are kept around so
/// that editing a 3D or measured geometry does not silently drop them.
@immutable
class GeoVertex {
  final LatLng position;
  final double? z;
  final double? m;

  const GeoVertex(this.position, {this.z, this.m});

  GeoVertex.fromPoint(data.Point point)
    : position = LatLng(point.y, point.x),
      z = point.z,
      m = point.m;

  GeoVertex moveTo(LatLng position) => GeoVertex(position, z: z, m: m);

  data.Point toPoint(int? srid, {required bool hasZ, required bool hasM}) =>
      data.Point(
        srid,
        position.longitude,
        position.latitude,
        hasZ ? z ?? 0 : null,
        hasM ? m ?? 0 : null,
      );

  @override
  bool operator ==(Object other) =>
      other is GeoVertex &&
      other.position == position &&
      other.z == z &&
      other.m == m;

  @override
  int get hashCode => Object.hash(position, z, m);

  @override
  String toString() => 'GeoVertex(${position.latitude}, ${position.longitude})';
}

/// Addresses a single vertex of the edited value.
///
/// [part] indexes into [GeoFeature.parts], [index] into that part. When used to
/// insert a vertex, [index] is the position the new vertex takes, so an [index]
/// equal to the part length appends to it.
@immutable
class GeoVertexRef {
  final int feature;
  final int part;
  final int index;

  const GeoVertexRef(this.feature, this.part, this.index);

  GeoVertexRef withIndex(int index) => GeoVertexRef(feature, part, index);

  @override
  bool operator ==(Object other) =>
      other is GeoVertexRef &&
      other.feature == feature &&
      other.part == part &&
      other.index == index;

  @override
  int get hashCode => Object.hash(feature, part, index);

  @override
  String toString() => 'GeoVertexRef($feature, $part, $index)';
}

/// A single shape of the edited value.
///
/// Features are immutable; all editing operations return a new feature or
/// `null` when the operation would degenerate the shape (a polygon with less
/// than three vertices for example), in which case the caller drops it.
sealed class GeoFeature {
  const GeoFeature();

  GeoFeatureKind get kind;

  /// The vertex lists this feature consists of.
  ///
  /// A point has a single part holding a single vertex, a line a single part
  /// and a polygon its outer ring followed by its holes.
  List<List<GeoVertex>> get parts;

  /// Whether the last vertex of every part connects back to its first.
  bool get isClosed;

  /// The number of vertices a part needs to remain valid.
  int get minVertices;

  /// Rebuilds this feature from [parts], returning `null` if the result would
  /// be degenerate.
  GeoFeature? withParts(List<List<GeoVertex>> parts);

  data.Geometry toGeometry(int? srid, {required bool hasZ, required bool hasM});

  Iterable<GeoVertex> get vertices => parts.expand((e) => e);

  Iterable<LatLng> get positions => vertices.map((e) => e.position);

  int get vertexCount => parts.fold(0, (sum, part) => sum + part.length);

  /// The number of vertices of a closed part, which includes the segment
  /// connecting its last vertex back to its first.
  int segmentCount(int part) =>
      isClosed ? parts[part].length : parts[part].length - 1;

  GeoFeature? moveVertex(GeoVertexRef ref, LatLng position) {
    final part = _partOf(ref);
    if (part == null || ref.index >= part.length) {
      return this;
    }

    return _replacePart(
      ref.part,
      part.copyWithReplaced(ref.index, part[ref.index].moveTo(position)),
    );
  }

  GeoFeature? insertVertex(GeoVertexRef ref, LatLng position) {
    final part = _partOf(ref);
    if (part == null || ref.index > part.length) {
      return this;
    }

    return _replacePart(
      ref.part,
      part.copyWithInserted(ref.index, GeoVertex(position)),
    );
  }

  GeoFeature? removeVertex(GeoVertexRef ref) {
    final part = _partOf(ref);
    if (part == null || ref.index >= part.length) {
      return this;
    }

    return _replacePart(ref.part, part.copyWithRemoved(ref.index));
  }

  GeoFeature? removePart(int index) {
    if (index < 0 || index >= parts.length) {
      return this;
    }

    return withParts(parts.copyWithRemoved(index));
  }

  GeoFeature? addPart(Iterable<GeoVertex> vertices) =>
      withParts([...parts, vertices.toList()]);

  List<GeoVertex>? _partOf(GeoVertexRef ref) =>
      ref.part >= 0 && ref.part < parts.length ? parts[ref.part] : null;

  GeoFeature? _replacePart(int index, List<GeoVertex> part) =>
      withParts(parts.copyWithReplaced(index, part));
}

class GeoPointFeature extends GeoFeature {
  final GeoVertex vertex;

  const GeoPointFeature(this.vertex);

  GeoPointFeature.at(LatLng position) : vertex = GeoVertex(position);

  @override
  GeoFeatureKind get kind => GeoFeatureKind.point;

  @override
  List<List<GeoVertex>> get parts => [
    [vertex],
  ];

  @override
  bool get isClosed => false;

  @override
  int get minVertices => 1;

  @override
  GeoFeature? withParts(List<List<GeoVertex>> parts) {
    final vertex = parts.firstOrNull?.firstOrNull;
    return vertex != null ? GeoPointFeature(vertex) : null;
  }

  @override
  data.Point toGeometry(int? srid, {required bool hasZ, required bool hasM}) =>
      vertex.toPoint(srid, hasZ: hasZ, hasM: hasM);

  @override
  bool operator ==(Object other) =>
      other is GeoPointFeature && other.vertex == vertex;

  @override
  int get hashCode => vertex.hashCode;
}

class GeoLineFeature extends GeoFeature {
  final List<GeoVertex> points;

  GeoLineFeature(Iterable<GeoVertex> points)
    : points = List.unmodifiable(points);

  @override
  GeoFeatureKind get kind => GeoFeatureKind.line;

  @override
  List<List<GeoVertex>> get parts => [points];

  @override
  bool get isClosed => false;

  @override
  int get minVertices => 2;

  @override
  GeoFeature? withParts(List<List<GeoVertex>> parts) {
    final points = parts.firstOrNull ?? const <GeoVertex>[];
    return points.length >= minVertices ? GeoLineFeature(points) : null;
  }

  @override
  data.LineString toGeometry(
    int? srid, {
    required bool hasZ,
    required bool hasM,
  }) => data.LineString(
    srid,
    [for (final point in points) point.toPoint(srid, hasZ: hasZ, hasM: hasM)],
    hasZ,
    hasM,
  );

  @override
  bool operator ==(Object other) =>
      other is GeoLineFeature && other.points.sequenceEquals(points);

  @override
  int get hashCode => Object.hashAll(points);
}

class GeoPolygonFeature extends GeoFeature {
  /// The outer ring followed by any holes, all stored without the repeated
  /// closing vertex.
  final List<List<GeoVertex>> rings;

  GeoPolygonFeature(Iterable<Iterable<GeoVertex>> rings)
    : rings = List.unmodifiable(rings.map(List<GeoVertex>.unmodifiable));

  @override
  GeoFeatureKind get kind => GeoFeatureKind.polygon;

  @override
  List<List<GeoVertex>> get parts => rings;

  @override
  bool get isClosed => true;

  @override
  int get minVertices => 3;

  List<GeoVertex> get outerRing => rings.first;

  Iterable<List<GeoVertex>> get holes => rings.skip(1);

  @override
  GeoFeature? withParts(List<List<GeoVertex>> parts) {
    final outer = parts.firstOrNull ?? const <GeoVertex>[];
    if (outer.length < minVertices) {
      return null;
    }

    return GeoPolygonFeature([
      outer,
      ...parts.skip(1).where((e) => e.length >= minVertices),
    ]);
  }

  @override
  data.Polygon toGeometry(
    int? srid, {
    required bool hasZ,
    required bool hasM,
  }) => data.Polygon(
    srid,
    [
      for (final ring in rings)
        data.LineString(
          srid,
          [
            for (final vertex in ring.followedBy([ring.first]))
              vertex.toPoint(srid, hasZ: hasZ, hasM: hasM),
          ],
          hasZ,
          hasM,
        ),
    ],
    hasZ,
    hasM,
  );

  @override
  bool operator ==(Object other) =>
      other is GeoPolygonFeature &&
      other.rings.length == rings.length &&
      other.rings.indexed.every((e) => e.$2.sequenceEquals(rings[e.$1]));

  @override
  int get hashCode => Object.hashAll(rings.map(Object.hashAll));
}
